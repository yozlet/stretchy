### Thank You!

Thanks for considering contributing to our project! We want to make Stretchy a great tool for integrating Elasticsearch with Ruby projects, and getting help from the community is always appreciated.

### Development

1. Fork it ( https://github.com/[my-github-username]/stretchy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Bugfixes

Please add a spec to reproduce the bug, fix it, then update any documentation necessary.

### Documentation Changes

If you notice we've got something wrong in the docs, please feel welcome to fix it.

### New Features

Before adding new features to the query builder, please [open a new issue](https://github.com/hired/stretchy/issues) to discuss it. This helps ensure your new feature is in line with the project's goals, and that you don't invest a bunch of time in something we might reject.

### Documentation

Our documentation is far from perfect, but if you add new methods to the query chain (ie, anything in `lib/stretchy/clauses`) be sure to document that using the YARD syntax, and also add it to the README.

### Testing

We use rspec for testing, with the latest version of Elasticsearch and Ruby. Until we hit 1.0, no support for older versions of either is planned.

* Use unit tests to ensure basic classes (builders, clauses, etc) behave the way you expect.
* Test the output of `.to_search` to ensure the JSON being generated for Elasticsearch is what you expect.
* Write an integration test under `spec/integration` to ensure that using your search terms actually affects the search results.

We run all specs automatically through Solano CI, and specs must pass there before any merge.

### Versioning

The version is only bumped on master after a pull request is merged. We use [Semantic Versioning](http://semver.org/).

* Bug fixes will bump the patch version
* Small new additions will bump the minor version
* Behavior and backwards-incompatible changes will bump the major version

### Style

1. Use the included `.editorconfig` to manage [minor style things like indents and tabs-v-spaces](http://editorconfig.org/).
2. Generally follow the [Github Ruby style guide](https://github.com/styleguide/ruby).
3. [Rebase your branch](http://git-scm.com/docs/git-rebase) and squash commits into reasonable chunks with good commit messages. No `@wip` or `fix specs` commits, please. [Here are some guidelines](http://chris.beams.io/posts/git-commit/) for good commit messages.
4. Write specs however they make sense to read. Use `describe` and `it` if your test names make a sentence, or `context` and `specify` for more specific unit tests.
