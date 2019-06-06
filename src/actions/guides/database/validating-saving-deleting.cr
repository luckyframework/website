class Guides::Database::ValidatingSavingDeleting < GuideAction
  ANCHOR_USING_WITH_HTML_FORMS = "perma-using-with-html-forms"
  guide_route "/database/validating-saving-deleting"

  def self.title
    "Validating, Saving, and Deleting"
  end

  def markdown
    <<-MD
    ## Form Objects

    How Lucky uses these, the structure, and where they go in the app. 

    ## Fillable Fields

    ## Creating Records

    Examples of passing in `params`, or how it would look being used in a task (i.e. seeing).

    ## Updating Records

    Ditto

    ### update!

    ## Delete Records

    Show example of passing in record, then call delete on the record.

    Link to the delete on the query page

    ## Validations

    * validate_required
    * validate_confirmation_of
    * validate_acceptance_of
    * validate_inclusion_of
    * validate_size_of
    * validate_uniqueness_of
    
    ### Custom validations

    ## Callbacks

    before / after
    save, create, update

    ## Extra Data

    Explain passing extra data in, using `needs` in a form, declaring on certain callbacks.

    ## Virtual Forms

    Explain virutal forms. Examples on when and how to use. Example in actions

    ### Virtual fields

    ### Validating virtual

    ## Common Form Conventions

    naming forms

    using `submit` method on virtual

    yield form and some object

    MD
  end
end
