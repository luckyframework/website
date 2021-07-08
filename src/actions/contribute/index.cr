class Contribute::Index < BrowserAction
  get "/contribute" do
    search_params = URI::Params.build do |form|
      form.add "q", "is:open is:issue org:luckyframework archived:false label:\"good first issue\""
    end

    redirect to: "https://github.com/issues?#{search_params}"
  end
end
