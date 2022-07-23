class HtmlConversions::NewPage < PageLayout
  needs input : String
  needs output : String

  def content
    div class: "my-4 mx-2" do
      h2 title, class: "text-3xl mb-4"

      para "Lucky uses Crystal classes and methods to generate HTML. It may sound crazy at first, but the advantages are numerous. Never accidentally print nil to the page, extract and share partials using regular methods. Easily read an entire page by looking at just the render method. Text is automatically escaped for security. And it’s all type safe. That means no more unmatched closing tags, and never rendering a page with missing data."
      tag "turbo-frame", id: "html-conversion" do
        form_for HtmlConversions::Create, class: "my-4 space-y-2" do
          div class: "space-y-1" do
            h3 "HTML Input", class: "text-2xl"
            textarea input, name: "input", class: "appearance-none mt-2 border-2 border-gray-200 rounded w-full py-2 px-4 leading-tight focus:outline-none focus:bg-white", placeholder: "Paste your HTML here", attrs: [:required], rows: 4
          end

          render_down_arrow
          render_convert_button
          render_down_arrow

          div class: "space-y-1" do
            div class: "flex items-center justify-between" do
              h3 "Lucky Output", class: "text-2xl"
              render_copy_button
            end

            pre class: "mt-2 #{output_default_height}" do
              code class: "h-full language-crystal hljs" do
                text output
              end
            end
          end
        end
      end
    end
  end

  private def render_copy_button
    div do
      textarea output,
        id: "code-copy-target",
        readonly: true,
        class: "sr-only whitespace-pre-wrap"

      button "Copy",
        id: "code-copy-button",
        class: "btn",
        type: "button",
        onclick: copy_button_javascript
    end
  end

  private def copy_button_javascript
    <<-JAVASCRIPT.lines.join(" ")
      document.querySelector("#code-copy-target").select();
      document.execCommand("copy");
      document.querySelector("#code-copy-button").innerHTML = "Copied!";
    JAVASCRIPT
  end

  private def render_convert_button
    div class: "text-center" do
      submit "Convert!", class: "btn w-full sm:w-2/3 md:w-1/2"
    end
  end

  private def render_down_arrow
    div class: "text-center text-2xl font-extrabold" do
      raw "&#8595"
    end
  end

  private def output_default_height
    if output.empty?
      "h-24"
    else
      "h-full"
    end
  end
end
