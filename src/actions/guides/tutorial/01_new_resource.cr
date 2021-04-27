class Guides::Tutorial::NewResource < GuideAction
  guide_route "/tutorial/new-resource"

  def self.title
    "Creating a New Resource"
  end

  def markdown : String
    <<-MD
    ## Using the Generator CLI

    Lucky comes with a lot of neat commands to make building your application a little easier.
    From your terminal, type `lucky -h`. Give it a moment to compile, then see a list of the commands you can use.

    For our next section, we will be generating a new "resource"; the "Fortune". In this context, a resource is a Model,
    Action, Page, Component, Query, and Operation.

    ### Planning the model

    Before we generate the new resource, we should plan out what this model will need.

    A `User` can write as many "fortunes" as they want, and each `Fortune` will belong to that user.
    The fortunes themselves will be a short bit of text. Pretty simple!

    ### Generating the model

    Let's run our generator command. The command breaks down like this:

    * The `lucky` CLI command
    * `gen.resource.browser` is the name of the command to run
    * `Fortune` is the name of our model
    * `text:String` is the name of the column and its type separated with a colon. You can add as many as you need here

    > Some shells may require the last portion to be wrapped in quotes. (i.e. `"text:String"`)

    The final command will look like this. Enter `lucky gen.resource.browser Fortune text:String`

    ```bash
    lucky gen.resource.browser Fortune text:String
    ```

    ## Running the Migration

    Lucky generated a migration file for us located in `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_create_fortunes.cr`.
    This migration file will generate a SQL statement for us that will create our "fortunes" table and add the columns our
    table needs like `text`, as well as a few other columns Avram gives to us for free; `id`, `created_at`, and `updated_at`.

    To execute this code, we will run the `db.migrate` task. Enter `lucky db.migrate`.

    ```bash
    lucky db.migrate
    ```

    > If you don't see output that says "Migrated", be sure to check spelling, and typos.

    Now that we've updated our database, we can boot our app to test a few things.

    Try this...

    * Boot your application. (`lucky dev`)
    * Sign in, then visit `/fortunes` in your browser.
    * Add a few fortunes, then edit one, and delete one.
    * Sign out of your account, then try to visit `/fortunes`. Notice how it asks you to sign in first?
    * Sign up a new account.
    * View the foruntes page, and notice you can edit the other users fortunes. Oops!

    We will fix the association issue in the next section.
    MD
  end
end
