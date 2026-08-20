require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "a category needs a name" do
    category = Category.new(name: "")
    assert_not category.valid?
  end

  test "two categories can't share the same name" do
    duplicate = Category.new(name: categories(:puns).name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "destroying a category with jokes still attached is blocked" do
    # jokes(:scarecrow) belongs to the "classic" category, so destroying that
    # category should be refused rather than silently orphaning the joke.
    category = categories(:classic)
    assert_not category.destroy
    assert_includes category.errors[:base].join, "Cannot delete record"
  end

  test "alphabetical orders categories by name" do
    assert_equal Category.order(:name).to_a, Category.alphabetical.to_a
  end
end
