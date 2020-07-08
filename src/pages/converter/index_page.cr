class ConvertHtmlToLucky::IndexPage < PageLayout
  needs input : String
  needs output : String

  def content
    div class: "my-4" do
      h2 @title, class: "text-3xl mb-4"
      para "Lucky uses Crystal classes and methods to generate HTML. It may sound crazy at first, but the advantages are numerous. Never accidentally print nil to the page, extract and share partials using regular methods. Easily read an entire page by looking at just the render method. Text is automatically escaped for security. And it’s all type safe. That means no more unmatched closing tags, and never rendering a page with missing data."

      div class: "flex my-4 space-x-4 items-stretch" do
        div class: "w-1/2" do
          h3 "HTML Input", class: "text-2xl"
          form_for ConvertHtmlToLucky::Create, class: "input-form" do
            textarea @input, name: "input", class: "appearance-none border-2 border-gray-200 rounded w-full py-2 px-4 leading-tight focus:outline-none focus:bg-white", placeholder: "Paste your HTML here", attrs: [:required]
            submit "Convert!", class: "btn btn-lg btn-success"
          end
        end

        div class: "w-1/2" do
          h3 "Lucky Output", class: "text-2xl"
          pre do
            code class: "language-crystal hljs" do
              text @output
            end
          end
        end
      end
    end
  end
end
