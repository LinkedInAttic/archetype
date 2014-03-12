# Archetype Warnings

## [archetype:breakpoint]

### [archetype:breakpoint] a breakpoint for \`$1\` is already set to \`$2\`, ignoring \`$3\`

#### What does this mean?

You tried registering a breakpoint using `register-breakpoint` that was already defined. To avoid conflicts with existing breakpoints, Archetype will ignore any reassignments.

#### Resolution:

You should register your breakpoint under a different name, or resolve the conflict.

### [archetype:breakpoint] could not find a breakpoint for \`$1\`

#### What does this mean?

You tried to invoke a breakpoint block which doesn't exist.

Here's an example that will cause this to happen:

```scss
@include breakpoint(non-existent-breakpoint) {
  ...
};
```

#### Resolution:

Make sure you're using the correct breakpoint name and that it has been properly registered via `register-breakpoint($name, $value)`.

## [archetype:hash]

### [archetype:hash] you're likely missing a comma or parens in your data structure: $1

#### What does this mean?

Archetype tried to convert a key-value pair `list` into a `hash`, but found an abnormality. This warning usually happens if you missed a comma or parentheses somewhere in your data structure.

#### Resolution:

Make sure you don't have any missing parentheses or commas in your data.

### [archetype:hash] one of your data structures is ambiguous, please double check near \`$1\`

#### What does this mean?

Archetype tried to convert a key-value pair `list` into a `hash`, but didn't find a value associated with the key.

Here's an example that will cause this to happen:

```scss
TODO
```

#### Resolution:

Make sure each of your keys has a value assigned to it.

## [archetype:css:derive]

### [archetype:css:derive] cannot disambiguate the CSS property \`$1\`

#### What does this mean?

TODO

#### Resolution:

TODO

### [archetype:css:derive] there isn't enough information to derive \`$1\`, so returning \`null\`

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:styleguide:missing_identifier]

### [archetype:styleguide:missing_identifier] \`$1\` does not contain an identifier. please specify one of: $2

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:grid]

### [archetype:grid] you can't divide a block into $1

#### What does this mean?

TODO

#### Resolution:

TODO

### [archetype:grid] you can't divide $1 columns

#### What does this mean?

TODO

#### Resolution:

TODO

### [archetype:grid] $1 of $2 columns is too small. Use a larger column size

#### What does this mean?

TODO

#### Resolution:

TODO

### [archetype:grid] table-cell method doesn't work yet!

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:glyph]

### [archetype:glyph] could not find a glyph library for \`$1\`, using default

#### What does this mean?

TODO

#### Resolution:

TODO

### [archetype:glyph] could not find character mapping for \`$1\`

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:bem]

### [archetype:bem] the current context may produce a non-standard BEM selector for ...

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:target:browser]

### [archetype:target:browser] using hack for ...

#### What does this mean?

TODO

#### Resolution:

TODO

## [archetype:units]

### [archetype:units] $1 is not unitless

#### What does this mean?

TODO

#### Resolution:

TODO

