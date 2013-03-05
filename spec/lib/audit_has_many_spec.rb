require "spec_helper"

describe "Has Many Association" do
  before(:each) do
    @book = Book.create!(name: 'MongoDB 101', read_count: 101)
  end

  it "track changes when child record is created" do
    expect {
      @book.comments.create!(title: 'Good Book', body: 'Awesome')
    }.to change { Book.audit_class.count }.by(1)
  end

  it "track changes when child record is updated" do
    comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

    expect {
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')
    }.to change { Book.audit_class.count }.by(1)
  end

  it "track changes when child record is deleted" do
    comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

    expect {
      comment.destroy
    }.to change { Book.audit_class.count }.by(1)
  end

  it "track changes when parent record is deleted" do
    comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

    expect {
      @book.destroy
    }.to change { Book.audit_class.count }.by(2)
  end
end