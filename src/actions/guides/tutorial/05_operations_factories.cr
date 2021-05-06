class Guides::Tutorial::OperationsFactories < GuideAction
  guide_route "/tutorial/operations-and-factories"

  def self.title
    "Operations and Factories"
  end

  def markdown : String
    <<-MD
    ## Saving Records to the Database

    Unlike other frameworks that use the model to save to the database, Lucky uses separate
    class objects called [SaveOperations](#{Guides::Database::SavingRecords.path}).
    These classes handle doing things like validations, ensuring parameter safety, and other
    complex business logic you may encounter.

    The SaveOperations go in your `src/operations/` directory, and will usually be named according to
    the action they are performing. (e.g. Saving a post would be `SavePost`)

    If you look in that directory now, you should see the `SignUpUser` class in `src/operations/sign_up_user.cr`.
    Open this file to take a look at the structure.

    ### SaveOperation breakdown

    In this file, we will see a few items. Here's what each part means:

    * `param_key :user` - Values from form fields passed in to this class must be prefixed with the `user` key.
    * `include PasswordValidations` - SaveOperations are plain Crystal classes which allows you to include modules when you need
    * `permit_columns email` - Only permit `email` to be passed in from params. (`user:email=my@email.com`)
    * `attribute password : String` - A virtual attribute that can be passed in, but not related to a database column
    * `before_save` - A callback to run a block of code before we save this record.
    * `validate_uniqueness_of email` - A built-in validation to check uniqueness of the `email` column
    * `Authentic.copy_and_encrypt password, to: encrypted_password` - Used to turn a plain "password" in to an encrypted string

    ### Playing with SaveOperation

    We can get a quick feel for these by using the `exec` cli task in our terminal. Enter `lucky exec`.

    ```bash
    lucky exec
    ```

    You should now have the code editor open, which may still show code from the last time we ran this.
    We can delete the old code we wrote (or comment it out), and just focus on writing some new code. Add this:

    ```crystal
    SignUpUser.create(email: "mytest@test.com", password: "notsecret", password_confirmation: "not_secret") do |operation, saved_user|
      pp operation.errors
      pp saved_user
    end
    ```

    Once done, save and exit the file. It will compile, then it will print out a `Hash(String, Array(String))` object, and `nil`. From this we
    can see that our SaveOperation has a `create` method that will take named args of what the operation requires from us. Then it takes a block
    that will pass the operation instance, and the saved user (if one exists). The `operation` has an `errors` method allowing us to inspect what
    errors we get back, and why we don't have a `saved_user` object.

    > Since we're not using a form here, we can [save without params](#{Guides::Database::SavingRecords.path(anchor: Guides::Database::SavingRecords::ANCHOR_SAVING_WITHOUT_PARAMS)}).

    Now hit `enter` to go back and edit the code. Fix the `password_confirmation` so they match, and save & exit. This time we see an empty hash `{}`,
    and our new `User` instance.

    > For more information on saving records, read the [Saving and Updating Records](#{Guides::Database::SavingRecords.path}) guide.

    ## Creating Sample Data

    In development, we may need our database to be a little more filled with data to really interact with it. For this case, we can create some sample data.
    Lucky gives you two different "seed" tasks. One used for filling your database with required data `db.seed.required_data`, and one used for
    filling your database with some sample data `db.seed.sample_data`. You can find these two tasks in your `tasks/db/seed/` directory.

    When creating sample data, we can use the `Avram::Factory`. This is an object generally used in testing, but it's also great for sample data.
    We can supply minimal, or in some cases, no additional data to create a ton of objects for us. These factory objects live in your
    `spec/support/factories/` directory. If you look in there now, you should see a `UserFactory`.

    ### Factory breakdown

    Every Factory is directly tied to a SaveOperation which means that all columns in the Model are available in the Factory.
    The column methods in the Factory take an argument to set their value. You can also use the `sequence()` method
    to generate a new number each time you generate a new Factory record to keep things a bit more dynamic.

    ## Create a New Factory

    We will create a new Factory for our `Fortune` model. Create a new file in `spec/support/factories/fortune_factory.cr`.
    Add in this code:

    ```crystal
    # spec/support/factories/fortune_factory.cr
    class FortuneFactory < Avram::Factory
      def initialize
        text "Have a Lucky day! \#{rand(100)} \#{rand(100)} \#{rand(100)}"
        # Default assign to user 1
        user_id 1
      end
    end
    ```

    We must add a value for every required column. The autogenerated columns `id`, `created_at`, and `updated_at` are automatically
    assigned a value, so no need to add those.

    > It's important that the name of this class matches the name of the model (`Fortune`), and then ends in `Factory` (`FortuneFactory`).

    ### Adding sample data

    Now that we have our factories created, we can use these to create a bunch of sample data. Lucky has a task file for adding sample
    data in your `tasks/db/seed/sample_data.cr` file. Open that file, and we will update the `call` method with this code:

    ```crystal
    # tasks/db/seed/sample_data.cr
    def call

      10.times do
        user = UserFactory.create

        10.times do
          # override the default user_id
          FortuneFactory.create(&.user_id(user.id))
        end
      end

      puts "Done adding sample data"
    end
    ```

    With that file updated, we can now run our `db.seed.sample_data` cli task to execute this code. Enter `lucky db.seed.sample_data`

    ```bash
    lucky db.seed.sample_data
    ```

    You will see the "Done adding sample data" when it's complete. In the next steps, we will go over writing queries to view these
    new records.

    > For more information on creating sample data, read the [Creating Test Data](#{Guides::Testing::CreatingTestData.path}) guide.

    ## Your Turn

    Now that you know how to create records with both `SaveOperation` and `Avram::Factory`, take a moment to play with
    each to get used to them. Being comfortable with their interfaces will be very helpful later.

    Try this...

    * Try overriding the `UserFactory` email with your own custom dynamic value in the sample_data task.
    * Try changing the `FortuneFactory` text to mention the user's email.
    * Use `lucky exec` to manually create new `User` and `Fortune` records.

    MD
  end
end
