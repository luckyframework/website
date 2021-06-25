class Guides::Tutorial::Assocations < GuideAction
  guide_route "/tutorial/assocations"

  def self.title
    "Associating Models"
  end

  def markdown : String
    <<-MD
    ## New Migrations

    When we generated our migration, we didn't add a way to tie Fortunes to a specific User. It may be common
    that you will need to generate separate migrations to update models that already exist in your application.
    Let's try that now.

    ### Generating a new migration

    We will use the `gen.migration` cli task to create a new migration file that will add a reference to User from the
    "fortunes" table. Generate the migration like this:

    ```
    lucky gen.migration AddBelongsToUserForFortune
    ```

    Now we will open up the file that was generated in `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_belongs_to_user_for_fortune.cr`.

    ### Writing a migration

    In this file, you will see two methods; `migrate` and `rollback`. The `migrate` method is run when we move our migration forward (e.g. creating a new table).
    The `rollback` method is used to write the opposite of what `migrate` does. So if `migrate` creates a new table, then `rollback` should drop that table. You
    would use this to undo the last ran migration allowing you to fix, or revert your database schema.

    In our case, we want to alter the "fortunes" table so we can add our user reference to it. Add this code:

    ```crystal
    # db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_belongs_to_user_for_fortune.cr

    def migrate
      # FYI: We will run in to an error. Be sure to keep reading before running any code
      alter table_for(Fortune) do
        add_belongs_to user : User, on_delete: :cascade, fill_existing_with: :nothing
      end
    end

    def rollback
      alter table_for(Fortune) do
        remove_belongs_to :user
      end
    end
    ```

    Save that file, and we can run our migration.

    > For more information on migrations, read the [Migrations](#{Guides::Database::Migrations.path}) guide.

    ### Running our migration

    Each time we generate a new migration, we must run it so it will update our database.
    However, if we run our migration right now, we would see an error. Lucky ensures type-safety by
    adding the foreign key constraints and references. By specifying `user : User` for the type, we tell
    Lucky that this association is required. We could make it optional by using Crystal Nil Union `user : User?`,
    but this is an easy fix, so we will keep the code as is.

    > This error will only happen if you have fortune records. To see the error, run `lucky db.migrate`.

    ### Yak shaving

    Since we don't need any fortunes we created when playing with our app, we can just delete all of them to start
    fresh. This gives us a chance to see how we can run "one-off" queries similar to other frameworks that use REPL consoles.

    We will use the `exec` cli task which will open a code editor allowing us to write arbitrary Crystal code, including some Avram
    queries. Enter `lucky exec`.

    ```bash
    lucky exec
    ```

    Once your code editor opens, you can write your query code below all of the comments. We will use the `FortuneQuery` object
    which is defined in `src/queries/fortune_query.cr`.

    Add this code:

    ```crystal
    require "../../src/app.cr"

    puts "Truncating the Fortunes table"

    FortuneQuery.truncate

    puts "done!"
    ```

    Once added, save and exit the file. This will tell Lucky to compile the code, and execute it, which will run a `TRUNCATE` on
    the "fortunes" table. When it's complete, you'll see a message that tells you to hit `enter` to run more commands, or `q` to quit.
    We are done here, so type `q`, then hit enter to quit.

    With the old data cleared out, postgres should allow us to add our foreign key constraint. We can now safely run our migration.
    Enter `lucky db.migrate`.

    ```bash
    lucky db.migrate
    ```

    ## Updating the Models

    Associations work in two parts; the database, and the model. We update the database by writing our migration, so now we just need
    to update the models.

    Open up the file `src/models/user.cr`. This `User` model was generated when we ran our setup wizard.

    At the bottom of the `table` block, we will add this new code:

    ```diff
    # src/models/user.cr

    table do
      column email : String
      column encrypted_password : String

    + has_many fortunes : Fortune
    end
    ```

    Next we will update our `Fortune` model in `src/models/fortune.cr` with this code:

    ```diff
    # src/models/fortune.cr

    table do
      column text : String

    + belongs_to user : User
    end
    ```

    > For more information on models, read the [Database Models](#{Guides::Database::Models.path}) guide.

    ## Your Turn

    At this point, our models are associated, but the application no longer works how we expect.
    To create a new fortune, we have to save it with the current user, but this will require some refactoring.

    For now, let's ensure our application boots up. If it fails, we can use this time to correct any issues.

    Try this:

    * Boot your application. (`lucky dev`)
    * Sign in, and try to create a fortune. Notice it fails
    * View your logs to see "Failed to save SaveFortune".
    * Use `lucky exec` to truncate all `User` records.
    * Then use your app to make a new user record, because we still need one 😄

    We will update the forms later in the tutorial.

    MD
  end
end
