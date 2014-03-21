# Contributing to Archetype

1. Fork *Archetype*
  - New to GitHub? Read this great article about [forking and contributing to open-source projects on GitHub](https://help.github.com/articles/fork-a-repo)
2. Update the Issue Tracker
  - if there's already an open ticket, feel free to comment on it or ask any follow up questions
  - if there isn't a ticket, create one and let us know what you plan to do
  - we like to keep an open dialog with developers :)
3. Code away!
4. Update or create test cases for your changes
5. Make sure all tests are passing `rake test`
6. Commit and push your changes (referencing any related issues in the comment)
7. Finally, create a [Pull Request](https://help.github.com/articles/creating-a-pull-request)

## Testing

Don't be **that guy** that broke the build. Tests help us ensure that everything is functioning the way it _should_ be and help us ensure back-compat, or provide a clean migration path.

When making changes to Archetype code, there should (almost always) be accompanying test cases. If you're modifying existing functionality, make sure the current tests are passing, or update them to be accurate.
If you're adding new functionality, you must also add test cases to cover it's behavior.

To run the test cases, simply run:

```sh
bundle exec rake test
```

### Testing SCSS changes, mixins, or module methods

Changes to SCSS files usually warrant stylesheet integration tests. These tests live in `test/fixtures/stylesheets/archetype/`.

Write the test source as \*.scss files in the `source/` directory. Write the expected results as \*.css files in the `expected/` directory.

When adding new tests, you can use the `rake test:update` helper task to verify the changes.

**Example:**

```sh
$ rake test:update
checking test cases...
The following changes were found:
====================================
[/new]  NEW TEST
> a {
>   font-size: 18px;
> }
[ui/example1]
3a4
>   color: green;
[ui/example2]
17d16
<   background: red;
====================================
Are all of these changes expected? [y/n]
```

If you answer `yes`, it will update the `expected` files. If you answer no, you will have to manually update the source and expected files.

### Testing Ruby changes and native methods

Ruby tests are currently limited to unit tests. These test cases live in `test/units`.

## Coding Standards

### General

- Use two "soft spaces", not tabs for indentation
- Always use proper indentation

### Ruby

- Use an explicit `return` for _functional methods_
- Return `true` or `false` for the success/failure status of _procedural methods_
- Internal methods should be `protected` or `private`
- Exposed methods intended for internal use only should be prefixed with an underscore (e.g. `_my_secret_method`)
  - changes to these exposed _faux-private_ methods don't require a major/minor version bump
- Use RDoc syntax for documenting all methods

### SCSS

- Function and mixin parameters should be lowercase and hyphenated (e.g. `$this-is-awesome`)
- Configuration variables should be uppercase, underscored, and prefixed with `CONFIG` (e.g. `$CONFIG_CHANGE_ME`)
- Configuration variables should be defined using `!default`
- Core constants should be uppercase, underscored, and prefixed with `CORE` (e.g. `$CORE_SOMETHING_SPECIAL`)
- Styleguide components should be uppercase, underscored, and prefixed with `STYLEGUIDE` (e.g. `$STYLEGUIDE_NEW_COMPONENT_ID`)
- Use multi-line convention with each rule on a separate line
- Use a semi-colon after every declaration (including the last declaration of a rule)
- Use the convention `$a-blackhole: my-procedural-method() !global;` when you're not using the value returned by a method
- Use Sassdoc syntax for documenting all methods
