class Guides::Database::CallbacksAndValidations < GuideAction
  ANCHOR_ATTRIBUTES = "perma-attributes"
  guide_route "/database/callbacks-and-validations"

  def self.title
    "Callbacks and Validations"
  end

  def markdown : String
    <<-MD
    ## Callbacks

    Callbacks are a way to hook in to the flow of the save operation allowing you to run custom code during
    a specific stage of the operation.

    ### Callbacks for running before and after save

    * `before_save` - Ran before the record is saved.
    * `after_save` - Ran after the record is saved, but before the transaction has committed.
    * `after_commit` - Ran after `after_save`, and the database transaction has committed.

    Create a method you'd like to run and then pass the method name to the
    callback macro. Note that the methods used by the `after_*` callbacks needs
    to accept the newly created record. In this example, a `Post`.

    ```crystal
    class SavePost < Post::SaveOperation
      before_save run_this_before_save
      after_save run_this_after_save
      after_commit run_this_after_commit

      def run_this_before_save
        # do something
      end

      def run_this_after_save(newly_created_post : Post)
        # do something
      end

      def run_this_after_commit(newly_created_post : Post)
        # do something
      end
    end
    ```

    Each callback macro also has a block form you can use. The `after_` callbacks require a block argument that passes down
    the newly created record. In this example, a `User`.

    ```crystal
    class SaveUser < User::SaveOperation
      before_save do
        # do something
      end

      after_save do |the_user|
        # do something
      end

      after_commit do |the_user|
        # do something
      end
    end
    ```

    > The `after_` callbacks will pass down the existing updated object when updating an existing record.

    ### When to use `after_save` vs. `after_commit`

    The `after_save` callback is a great place to do other database saves because if something goes
    wrong the whole transaction would be rolled back.

    ```crystal
    class SaveComment < Comment::SaveOperation
      after_save also_update_post

      # If this fails, we roll back the comment save too
      def also_update_post(saved_comment : Comment)
        SavePost.update!(latest_comment: saved_comment.body)
      end
    end
    ```

    The `after_commit` callback is best used for things like email notifications and such
    since this is only called if the records were actually saved in to the database.

    ```crystal
    class SaveComment < Comment::SaveOperation
      after_commit notify_user_of_new_comment

      def notify_user_of_new_comment(new_comment : Comment)
        NewCommentNotificationEmail.new(new_comment, to: comment.author!).deliver_now
      end
    end
    ```

    ## Conditional Callbacks

    Callbacks by default will always run, but in some cases, you may need a specific callback to run based on
    some condition. The recommended way would be to think about splitting your operations in to separate classes.
    For example, saving a coupon for a new user, but only if that user is a friend.

    ```crystal
    class SaveStandardUser < User::SaveOperation
      include ThingsNeededToSaveUser
    end

    class SaveFriendUser < User::SaveOperation
      include ThingsNeededToSaveUser

      before_save do
        # save coupon
      end
    end
    ```

    As an alternative method to breaking out operations, we've also added the `if` and `unless` conditions to
    `before_save`, `after_save`, and `after_commit`.

    ```crystal
    class SaveUser < User::SaveOperation
      before_save :save_coupon, if: :user_is_a_friend?
      # or use `unless`
      # before_save :save_coupon, unless: :user_is_standard?

      private def save_coupon
        # save coupon
      end

      private def user_is_a_friend?
        # returns true if user is a friend
      end
    end
    ```

    The `Symbol` passed to `if` and `unless` should be the name of a method that returns a `Bool`.

    ## Validations

    Before you save data to your database, it's important to ensure the data is both safe, and valid.
    By using validations with your `SaveOperation` objects, you can ensure your database will stay clean.

    Lucky comes with a few built in validations:

    | Validator                   | Description                                            | Example                                                          |
    |-----------------------------|--------------------------------------------------------|------------------------------------------------------------------|
    | validate_required           | ensures that a field is not `nil` or blank (e.g. `""`) | `validate_required email`                                        |
    | validate_confirmation_of    | ensures that 2 fields have the same values             | `validate_confirmation_of password, with: password_confirmation` |
    | validate_acceptance_of      | ensure that a bool value is true                       | `validate_acceptance_of terms_of_service`                        |
    | validate_inclusion_of       | check that value is in a list of accepted values       | `validate_inclusion_of membership, in: ["active", "pending"]`    |
    | validate_size_of            | ensure a string is an exact length                     | `validate_size_of token, is: 16`                                 |
    | validate_size_of            | ensure a string is within a length range               | `validate_size_of username, min: 3, max: 11`                     |
    | validate_uniqueness_of      | ensure a value doesn't exist in the database already   | `validate_uniqueness_of email, query: UserQuery.new.email`       |
    | validate_at_most_one_filled | check that only 1 of the attributes has a value        | `validate_at_most_one_filled choice1, choice2, choice3`          |
    | validate_exactly_one_filled | ensure exactly 1 attribute has a value                 | `validate_exactly_one_filled photo_id, video_id`                 |
    | validate_numeric            | ensure a number is within the range specified          | `validate_numeric age, greater_than: 20, less_than: 30`          |

    > Note: non-nilable (required) fields automatically use `validate_required`.
    > They will run after all other `before_save` callbacks have run. This way data
    > with missing fields will never be sent to the database.

    ### Using validations

    All of the validations require an `Avram::Attribute` to be passed in.

    You can use validations inside of `before_save` callbacks:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name, terms_of_service, age
      attribute password : String
      attribute password_confirmation : String

      before_save do
        validate_required name
        validate_confirmation_of password, with: password_confirmation
        validate_acceptance_of terms_of_service
        validate_inclusion_of age, in: [30, 40, 50]
        validate_uniqueness_of name
        # Alternatively, pass optional second argument to use a custom query
        validate_uniqueness_of name, query: UserQuery.new.name.lower
        # Showing these version as an example
        # You would not want all three of these on a real form
        validate_size_of name, is: 4 # Name must be 4 characters long
        validate_size_of name, min: 4 # Can't be too short
        validate_size_of name, max: 8 # Must have a short name
      end

      before_save reject_scary_monsters

      def reject_scary_monsters
        if name.value == "Skeletor"
          name.add_error "Mmmyyaahhh!"
        end
      end
    end
    ```

    ### Custom error messages

    When a validation fails, an error message will be applied to the attribute automatically. For example,
    the `validate_required` will return `"is required"`, and the `validate_acceptance_of` will return `"must be accepted"`.

    You can pass a `message` option to any of the attributes to define your own custom error message.

    ```crystal
    before_save do
      validate_required name, message: "se requiere"
      validate_confirmation_of email, with: email_confirmation, message: "debe coincidir con"
    end
    ```

    #{permalink(ANCHOR_ATTRIBUTES)}
    ## What are attributes?

    Attributes defined in the operation do not return the value of the attribute. They return an `Avram::Attribute`
    that contains the value of the attribute, the name of the attribute, the param value, and any errors the attribute
    has.

    This means that to access their value you must call `value` on the attribute.

    ```crystal
    class SaveUser < User::SaveOperation
      def print_name_value
        pp name.value
      end
    end
    ```

    > All of the columns from a model exist in SaveOperations as attributes, as well as any additional `attribute` specified.

    ## Custom validations

    You can easily create your own validations. For example, let’s say we want to
    make sure the user is old enough to use the site.

    ```crystal
    before_save validate_user_is_old_enough

    private def validate_user_is_old_enough
      # The value might be `nil` so we need to use `try`.
      age.value.try do |value|
        if value < 13
          age.add_error "must be at least 13 to use this site"
        end
      end
    end
    ```

    ## Sharing common validations, callbacks, etc.

    When using multiple operations for one model you often want to share a common set of
    validations, allowances, etc.

    You can do this with a module:

    ```crystal
    # src/operations/mixins/age_validation.cr
    module AgeValidation
      private def validate_old_enough_to_use_website
        # The value of age might be `nil` so we need to use `try`
        age.value.try do |value|
          if value < 13
            age.add_error "must be at least 13 to use this site"
          end
        end
      end
    end
    ```

    Then in your operation:

    ```crystal
    # src/operations/save_admin_user.cr
    class SaveAdminUser < User::SaveOperation
      include AgeValidation
      permit_columns email, age

      before_save do
        validate_old_enough_to_use_website
        admin.value = true
      end
    end
    ```

    Callbacks can be automatically included by adding them to an `included` macro. This allows multiple operations to use the
    same callbacks.

    ```crystal
    # src/operations/mixins/code_validator.cr
    module CodeValidator
      macro included
        needs code : String

        before_save run_special_code_validation
      end

      private def run_special_code_validation
        # ...
      end
    end
    ```

    Then in your operation:

    ```crystal
    # src/operations/save_message.cr
    class SaveMessage < Message::SaveOperation
      include CodeValidator

      before_save do
        # other validations
      end
    end

    # src/operations/save_transaction.cr
    class SaveTransaction < Transaction::SaveOperation
      include CodeValidator
    end
    ```
    MD
  end
end
