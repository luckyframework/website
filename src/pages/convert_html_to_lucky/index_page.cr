class ConvertHtmlToLucky::IndexPage < PageLayout
  needs input : String
  needs output : String

  def content
    div class: "md:mt-12" do
      h2 @title
      para "Lucky uses Crystal classes and methods to generate HTML. It may sound crazy at first, but the advantages are numerous. Never accidentally print nil to the page, extract and share partials using regular methods. Easily read an entire page by looking at just the render method. Text is automatically escaped for security. And it’s all type safe. That means no more unmatched closing tags, and never rendering a page with missing data."

      div class: "md:mt-6" do
        h3 "HTML Input"
        form_for ConvertHtmlToLucky::Create, class: "input-form" do
          textarea @input, name: "input", class: "form-control html-input", placeholder: "Paste your HTML here", attrs: [:required]
          submit "Convert!", class: "btn btn-lg btn-success"
        end
      end

      div class: "md:mt-6" do
        h3 "Lucky Output"
        pre do
          code class: "language-crystal hljs" do
            text @output
          end
        end
      end
    end
  end
end
