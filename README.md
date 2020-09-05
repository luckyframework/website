# Lucky's New Website

### Future guide goals

* Add screencasts
* *Versioned*. Look at old ones, or even look at what's on master
* Link to relevant screencasts
* Helpful or not button
  * If not, direct to Discord to get help
* Check code snippets in real projects. More confidence code samples work.

## Setting up the project

1. [Install required dependencies](https://luckyframework.org/guides/getting-started/installing#install-required-dependencies)
1. Run `script/setup`
1. Run `lucky dev` to start the app
1. Visit `http://localhost:5000`

## Editing guides

Guides are located in the `src/actions/guides`. You can edit the markdown in each action file and view changes by running the Lucky app with `lucky dev`

## Adding a new guide

1. Create a new guide in `src/actions/guides`. Usually it is easiest to copy an existing guide as a starting point
1. Add the guide class to the appropriate category in the [GuidesList](https://github.com/luckyframework/website/blob/master/src/models/guides_list.cr)
1. That's it! View your guide by running `lucky dev` and ginding the guide in the sidebar.

### Learning Lucky

Lucky uses the [Crystal](https://crystal-lang.org) programming language. You can learn about Lucky from the [Lucky Guides](http://luckyframework.org/guides).
