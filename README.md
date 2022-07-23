# Lucky's Website

This is the repository for Lucky's official website https://luckyframework.org/

## Setting up the project

1. [Install required dependencies](https://luckyframework.org/guides/getting-started/installing#install-required-dependencies)
1. Ensure you have `cmake` and `libxml2` installed for your system. These are required for some shard dependencies of this project
1. Run `script/setup`
1. Run `lucky dev` to start the app
1. Visit `http://localhost:5000`

## Editing guides

Guides are located in the `src/actions/guides` directory. You can edit the markdown in each action file and view changes by running the Lucky app with `lucky dev`.

## Adding a new guide

1. Create a new guide in `src/actions/guides`. Usually it is easiest to copy an existing guide as a starting point
1. Add the guide class to the appropriate category in the [GuidesList](https://github.com/luckyframework/website/blob/main/src/models/guides_list.cr)
1. That's it! View your guide by running `lucky dev` and ginding the guide in the sidebar.

### Learning Lucky

Lucky uses the [Crystal](https://crystal-lang.org) programming language. You can learn about Lucky from the [Lucky Guides](http://luckyframework.org/guides). Get help on our [Discord](https://luckyframework.org/chat) server.
