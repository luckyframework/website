class Guides::JsonAndApis::ParsingJsonRequests < GuideAction
  guide_route "/json-and-apis/parsing-json-requests"

  def self.title
    "Parsing JSON Requests"
  end

  def markdown : String
    <<-MD
    ## Converting JSON params to objects

    Crystal comes with a [JSON::Serializable](https://crystal-lang.org/api/1.0.0/JSON/Serializable.html) module that makes converting raw JSON in to
    composable objects much easier. This makes validating your JSON, and storing the data nicer and type-safe.

    We will use this JSON object for an example:

    ```json
    {
      "pay_date": "2021-02-15 10:00:00",
      "issue_date": "2021-01-31 14:00:00",
      "lines": [
        {"text": "Item One", "unit": "USD", "amount": 5500, "tax": 3.8},
        {"text": "Item Two", "unit": "USD", "amount": 1032, "tax": 3.8},
      ]
    }
    ```

    ### Using params

    The `params` object gives us access to this JSON with `params.body`. We can also access individual values with `params.from_json["the_key"]`.

    ```crystal
    class Api::Invoices::Create < ApiAction
      post "/api/customers/:customer_id/invoices" do
        pay_date = Time.parse(params.from_json["pay_date"].as_s, "%Y-%m-%d %H:%M:%S", Time::Location::UTC)

        SaveInvoice.create(pay_date: pay_date) do |op, invoice|
          # ...
        end
      end
    end
    ```

    To simplify the code a bit, we can create separate JSON serializable objects.

    ```crystal
    class SerializedInvoice
      include JSON::Serializable
      property pay_date : Time
      property issue_date : Time
      property lines : Array(SerializedInvoiceLine)
    end

    class SerializedInvoiceLine
      include JSON::Serializable
      property text : String
      property unit : String
      property amount : Int32
      property tax : Int32
    end
    ```

    With these two classes, we can use `params.body` to clean up our action!

    ```crystal
    class Api::Invoices::Create < ApiAction
      post "/api/customers/:customer_id/invoices" do
        serialized_invoice = SerializedInvoice.from_json(params.body)

        SaveInvoice.create(serialized_invoice: serialized_invoice) do |op, invoice|
          # ...
        end
      end
    end
    ```
    
    We will have to tell the `SaveInvoice` operation how to handle the serialized object.
    
    ```crystal
    class SaveInvoice < Invoice::SaveOperation
      needs serialized_invoice : SerializedInvoice
    
      before_save do
        pay_date.value = serialized_invoice.pay_date
        issue_date.value = serialized_invoice.issue_date
        # ...
      end
    end
    ```
    MD
  end
end
