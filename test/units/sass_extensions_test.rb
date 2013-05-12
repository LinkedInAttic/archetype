require 'test_helper'
require 'archetype'

class SassExtensionsTest < Test::Unit::TestCase
  setup do
    Compass.reset_configuration!
  end

  ## VERSION
  # test that archetype-version() is working correctly
  def test_version
    version_pattern = /\d+(\.\d+)*(\.[x|\*])?/
    assert_equal Archetype::VERSION.match(version_pattern)[0], evaluate("archetype-version()")
    assert_equal Compass::VERSION.match(version_pattern)[0], evaluate("archetype-version(compass)")
    assert_equal Sass::VERSION.match(version_pattern)[0], evaluate("archetype-version(sass)")
    assert_equal "true", evaluate("archetype-version('Compass >= 0.12')")
    assert_equal "false", evaluate("archetype-version('Sass >= 99.0.0')")
    assert_equal "true", evaluate("archetype-version('Sass gt 3.0')")
    assert_equal "true", evaluate("archetype-version(Archetype ne 99)")
  end


  ## ENVIRONMENT
  # test that archetype-env() is working correctly
  def test_env
    Compass.reset_configuration!
    assert_equal "development", evaluate("archetype-env()")
    Compass.configuration.environment = :production
    assert_equal "production", evaluate("archetype-env()")
    Compass.configuration.environment = :staging
    assert_equal "staging", evaluate("archetype-env()")
    Compass.reset_configuration!
  end


  ## LISTS
  # list-replace
  def test_list_replace
    # TODO
  end

  # list-remove
  def test_list_remove
    # TODO
  end

  # list-insert
  def test_list_insert
    # TODO
  end

  # list-sort
  #def test_list_sort
  #  assert_equal "1 2 3 4", evaluate("list-sort(2 4 3 1)")
  #  assert_equal "4 3 2 1", evaluate("list-sort(2 4 3 1, true)")
  #  assert_equal "a b c d", evaluate("list-sort(d a b c)")
  #end

  # list-reverse
  #def test_list_reverse
  #  assert_equal "4 3 2 1", evaluate("list-reverse(1 2 3 4)")
  #  assert_equal "d c b a", evaluate("list-reverse(a b c d)")
  #end

  # list-add
  def test_list_add
    assert_equal "2 3 4", evaluate("list-add(1 2 3, 1)")
    assert_equal "5 6 7", evaluate("list-add(1 2 3, 4)")
    assert_equal "5 7 9", evaluate("list-add(1 2 3, 4 5 6)")
  end

  # list-subtract
  def test_list_subtract
    assert_equal "0 1 2", evaluate("list-subtract(1 2 3, 1)")
    assert_equal "1 2 3", evaluate("list-subtract(5 6 7, 4)")
    assert_equal "1 2 3", evaluate("list-subtract(5 7 9, 4 5 6)")
  end

  # list-multiply
  def test_list_multiply
    assert_equal "2 4 6", evaluate("list-multiply(1 2 3, 2)")
    assert_equal "20 24 28", evaluate("list-multiply(5 6 7, 4)")
    assert_equal "20 35 54", evaluate("list-multiply(5 7 9, 4 5 6)")
  end

  # list-divide
  def test_list_divide
    assert_equal "2/2 4/2 6/2", evaluate("list-divide(2 4 6, 2)")
    assert_equal "20/4 24/4 28/4", evaluate("list-divide(20 24 28, 4)")
    assert_equal "20/4 35/5 54/6", evaluate("list-divide(20 35 54, 4 5 6)")
  end

  # list-mod
  def test_list_mod
    assert_equal "1 0 1", evaluate("list-mod(1 2 3, 2)")
    assert_equal "0 1 2", evaluate("list-mod(4 5 6, 4)")
    assert_equal "3 2 1", evaluate("list-mod(15 17 19, 4 5 6)")
  end

  # index2
  def test_index2
    assert_equal "1", evaluate("index2(a b c, a)")
    assert_equal "4", evaluate("index2(a b c f, d e f)")
    assert_equal "false", evaluate("index2(a b c, d)")
    assert_equal "false", evaluate("index2(a b c, d e f)")
  end

  # nth-cyclic
  def test_nth_cyclic
    assert_equal "a", evaluate("nth-cyclic(a b c, 1)")
    assert_equal "b", evaluate("nth-cyclic(a b c, 2)")
    assert_equal "b", evaluate("nth-cyclic(a b c, 5)")
    assert_equal "c", evaluate("nth-cyclic(a b c, 24)")
  end

  # associative
  def test_associative
    # TODO
  end

  # associative-merge
  def test_list_associative_merge
    # TODO
  end


  ## LOCALE
  # locale
  def test_locale
    Compass.reset_configuration!
    assert_equal "en_US", evaluate("locale()")
    Compass.configuration.locale = "ja_JP"
    assert_equal "ja_JP", evaluate("locale()")
    Compass.reset_configuration!
  end

  # lang
  def test_lang
    Compass.reset_configuration!
    assert_equal "true", evaluate("lang(en_US)")
    assert_equal "true", evaluate("lang(fr_FR en_US)")
    assert_equal "false", evaluate("lang(fr_FR)")
    Compass.configuration.locale = "ja_JP"
    assert_equal "false", evaluate("lang(en_US)")
    assert_equal "true", evaluate("lang(ja_JP)")
    assert_equal "true", evaluate("lang(CJK)")
    assert_equal "true", evaluate("lang(CJK en_US)")
    Compass.reset_configuration!
  end


  ## NUMBERS
  def test_strip_units
    assert_equal "12", evaluate("strip-units(12px)")
    assert_equal "0.5", evaluate("strip-units(0.5em)")
    assert_equal "20", evaluate("strip-units('20rem')")
    assert_equal "0", evaluate("strip-units(10 somethings)") # this is a failure, so returns 0
  end


  ## STYLEGUIDE
  # styleguide-add-component
  def test_styleguide_add_component
    # TODO - this is a more complex test
  end

  # styleguide-extend-component
  def test_styleguide_extend_component
    # TODO - this is a more complex test
  end

  # styleguide
  def test_styleguide
    # TODO - this is a more complex test
  end

  # styleguide-diff
  def test_styleguide_diff
    # TODO - this is a more complex test
  end


  ## UI
  # test generating unique tokens
  def test_unique
    assert_equal ".archetype-uid-1", evaluate("unique(class)")
    assert_equal ".archetype-uid-2", evaluate("unique(class)")
    assert_equal "\#archetype-uid-3", evaluate("unique(id)")
    assert_equal "my-prefix-archetype-uid-4", evaluate("unique(my-prefix-)")
    assert_equal ".testing-archetype-uid-5", evaluate("unique('.testing-')")
  end

  # test pseudo content escaping and formatting for innerHTML
  def test_ie_pseudo_content
    assert_equal "this is a test", evaluate("-ie-pseudo-content(this is a test)")
    assert_equal "this is &gt; awesome", evaluate("-ie-pseudo-content('this is > awesome')")
    assert_equal "tests &amp; more tests", evaluate("-ie-pseudo-content('tests & more tests')")
    assert_equal "testing unicode &\#x2079;", evaluate("-ie-pseudo-content('testing unicode \\2079')")
    assert_equal "a character &\#x2079; mid-sentence", evaluate("-ie-pseudo-content('a character \\2079  mid-sentence')")
    assert_equal "&\#x2079;", evaluate("-ie-pseudo-content('\\2079')")
  end

protected
  def evaluate(value)
    Sass::Script::Parser.parse(value, 0, 0).perform(Sass::Environment.new).to_s
  end
end
