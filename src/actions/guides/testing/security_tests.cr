class Guides::Testing::SecurityTests < GuideAction
  guide_route "/testing/security-tests"

  def self.title
    "Security Tests with BrightSec"
  end

  def markdown : String
    <<-MD
    ## Getting Started

    [BrightSec](https://brightsec.com/) (formerly NeuraLegion) provides a no false positive,
    Dynamic Application Security Testing (DAST) scanner to automatically test your application
    against common vulnerabilities like [cross-site scripting (XSS)](https://brightsec.com/blog/xss/),
    [IP & header spoofing](https://www.cloudflare.com/learning/ddos/glossary/ip-spoofing/),
    [SQL Injection (SQi)](https://brightsec.com/blog/sql-injection-attack/),
    and cookie tampering, for example.

    By integrating the BightSec [SecTester](https://github.com/NeuraLegion/sec_tester), we can
    easily test our Lucky applications to ensure we're not pushing major security holes in to production.
    To get started, we will need to create a free account and generate a new API key.

    New Lucky applications can generate the configuration as well as a full spec suite. Use the `init.custom`
    command with the `--with-sec-test` flag to generate your application.

    ```bash
    lucky init.custom my_app --with-sec-test
    ```

    This will generate a full web application with authentication, SecTester configuration, and specs
    that can be ran to test your application. Before we run that, we will need to get an API, and setup
    a few things.

    ## Setup

    ### Create a new API key

    Head over to [BrightSec Signup](https://brightsec.com/sign-up-for-bright?utm_source=luckyframework&utm_medium=luckywebsite&utm_campaign=luckysignup) and create your account.
    Once you're logged in, you can visit your [Profile](https://app.neuralegion.com/profile), and
    [generate a new API key](https://docs.brightsec.com/docs/manage-your-personal-account?utm_source=luckyframework&utm_medium=luckywebsite&utm_campaign=luckysignup#manage-your-personal-api-keys-authentication-tokens).
    For now, create with all scopes enabled; this can be customized later.

    Save this key in your `.env` file locally as `NEXPLOIT_TOKEN`.

    > The ENV is called from `spec/setup/sec_tester.cr`.

    ### Install the Nexploit Repeater

    The Nexploit Repeater is an NPM package that runs locally to send requests between your local
    application, and the BrightSec scans.

    ```bash
    npm install -g @neuralegion/nexploit-cli --unsafe-perm=true
    ```

    ### Running the specs

    Depending on how you generated your application (i.e. with/without auth, api/full, etc...),
    there will be several different tests generated for you. You can find these in your `spec/flows/security_spec.cr`
    file.

    Each of these tests can take a bit of time to run, so to save on scan time, when you run `crystal spec`,
    the security specs are skipped by default. In order to run these, you'll need to pass the `-Dwith_sec_tests`
    flag.

    ```bash
    crystal spec -Dwith_sec_tests
    ```

    You may also notice that your Github Actions CI in `.github/workflows/ci.yml` includes this flag
    ensuring that each CI run will run these tests.

    ## Common Vulnerabilities

    Here is a list of some of the more common vulnerabilities you may want to test your application for.

    ### sqli

    A SQL injection attack is the insertion (injection) of a malicious SQL query via the
    input data from a client to an application.

    This vulnerability allows an attacker to:

    * Modify application data
    * Bypass protection mechanism
    * Read application data

    [Read more on sqli](https://docs.brightsec.com/docs/sql-injection)

    ### jwt

    JSON Web Token (JWT) is an open standard that defines a compact and self-contained way
    for transmitting information as a JSON object securely between parties.

    This vulnerability allows an attacker to:

    * Gain privileges or assume identity
    * Bypass protection mechanism
    * Bypass authentication mechanism

    [Read more on jwt](https://docs.brightsec.com/docs/broken-jwt-authentication)

    ### xss / dom_xss

    XSS, or cross-site scripting, allows the attacker to execute arbitrary HTML and JavaScript in
    the user's browser. As a result, the attacker gets access to the application and can do
    anything that the victim (user) can on the client side (access any cookies, session tokens and other).

    This vulnerability allows an attacker to:

    * Execute unauthorized code or commands
    * Bypass protection mechanism
    * Read the application data
    * Deface the application

    [Read more on xss](https://docs.brightsec.com/docs/reflective-cross-site-scripting-rxss)

    ### ssrf

    SSRF, or server-side request forgery, allows the attacker to execute code by sending any request
    to any URL address through the victim application on the web server.

    This vulnerability allows the attacker to:

    * Gain sensitive information on the server
    * Get access to internal services
    * Get access to Databases if the access is allowed for internal network
    * Scan host ports on internal networks

    [Read more on ssrf](https://docs.brightsec.com/docs/server-side-request-forgery-ssrf)

    ### header_security

    By enabling certain headers in your web application and server settings, you can increase
    your web application resistance to many common attacks. Implementing the right headers is a
    crucial aspect of a best-practice application setup.

    This vulnerability may expose the application to the following attack vectors:

    * Cross-Site Scripting (XSS)
    * Clickjacking
    * Code injection

    [Read more on header_security](https://docs.brightsec.com/docs/misconfigured-security-headers)

    ### cookie_security

    A cookie is a small piece of data that a server sends to the user's web browser.
    The browser may store it and send it back with later requests to the same server.
    Typically, it is used to tell if two requests came from the same browser (keeping a user logged-in, for example).

    This vulnerability allows an attacker to read the application data.

    [Read more on cookie_seciryt](https://docs.brightsec.com/docs/sensitive-cookie-in-https-session-without-secure-attribute)

    > For more comprehensive documentation, visit the [BrightSec Vulnerability Guide](https://docs.brightsec.com/docs/vulnerability-guide).

    ## Writing a Test

    > To avoid running out of scan hours too quick, it's recommended to place your tests together in
    > `spec/flows/security_spec.cr` below the `skip_file` macro. This will ensure the specs are only
    > ran when explicitly told to with the `-Dwith_sec_tests` flag.

    Each test is ran within the `scan_with_cleanup` which is defined at the bottom of the spec file.
    This method just ensures the scanner is cleaned up between each test.

    ```crystal
    it "tests for header_security" do
      scan_with_cleanup do |scanner|
        # test goes here
      end
    end
    ```

    Next, we need to create our target. The target will be the route that we are testing the vulnerability
    against. The [LuckySecTester](https://github.com/luckyframework/lucky_sec_tester) shard gives us a nice
    Lucky integration which allows us to have compile-time checks against our Actions. If a path changes,
    the spec doesn't break.

    ```crystal
    it "tests for header_security" do
      scan_with_cleanup do |scanner|
        user = UserFactory.create &.username("h4x0r")
        target = scanner.build_target(Users::Show.with(user.slug))
        # ...
      end
    end
    ```

    > The `build_target` method can take any `Lucky::Action`, or `Lucky::RouteHelper`.

    Finally, we call the `scanner.run_check` method to execute the tests we want to check.

    ```crystal
    it "tests for header_security" do
      scan_with_cleanup do |scanner|
        user = UserFactory.create &.username("h4x0r")
        target = scanner.build_target(Users::Show.with(user.slug))
        scanner.run_check(
          scan_name: "Users::Show header_security test.",
          tests: [
            "header_security",
          ],
          target: target
        )
      end
    end
    ```

    ### scan_name

    This name is displayed on your BrightSec dashboard for each scan. You can use special ENV values
    from the CI (e.g. `ENV["GITHUB_REF"]`, `ENV["GITHUB_RUN_ID"]`) to ensure they're always unique,
    or set it to whatever you'd like.

    ### tests

    This is an array of strings that match the vulnerability names you want to test. You can test
    against one, or several different vulnerabilities.

    If you leave this value as `nil`, it will tell the SecTester to run against ALL of the available
    vulnerabilities.
    
    For more information about choosing and configuring the right tests visit the [SecTester Docs](https://github.com/NeuraLegion/sec-tester-cr#choosing-the-right-tests)

    ### target

    This is the `target` object we created. In some cases, you may need an escape hatch to build
    a custom target. You can use `SecTester::Target` directly for this.

    ```crystal
    target = SecTester::Target.new(Lucky::RouteHelper.settings.base_uri + Lucky::AssetHelpers.asset("js/app.js"))
    ```

    ### severity_threshold

    Some tests are a bit more strict than others. One case is with `cookie_security`, it will make sure
    that your cookies are set to HTTP only. However, Lucky only sets this value when HTTPS is enable,
    and HTTPS is only enabled in a Production environment. In this case, the spec would fail by default.

    For these cases, we can set the `severity_threshold` option to `SecTester::Severity::Medium`.

    > Values for this are `SecTester::Severity::High` (default), `SecTester::Severity::Medium`, and `SecTester::Severity::Low`.

    ## Customizing Targets

    If your action requires data to be sent such as a user signup, or user login, you can customize
    the data by passing a block to the `build_target`.

    ```crystal
    target = scanner.build_target(SignUps::Create) do |t|
      t.body = "user%3Aemail=aa%40aa.com&user%3Apassword=123456789&user%3Apassword_confirmation=123456789"
    end
    ```

    ### API actions

    When posting data to an API action, your data will most likely need to be JSON formatted. You'll
    also need to make sure you send the appropriate JSON headers.

    ```crystal
    api_headers = HTTP::Headers{"Content-Type" => "application/json", "Accept" => "application/json"}
    target = scanner.build_target(Api::SignIns::Create, headers: api_headers) do |t|
      t.body = {"user" => {
        "email" => "aa@aa.com", "password" => "123456789"
      }}.to_json
    end
    ```

    > The target `body` should always be a `String`. Be sure to call `to_json` when using a Hash-like structure.

    MD
  end
end
