require File.dirname(__FILE__) + '/spec_helper.rb'

# We'll override find to find by title

describe "custom find" do
  before(:each) do
    [Post,Comment].each(&:delete_all)
    @post1 = Post.create(:title => 'post1')
    @post2 = Post.create(:title => 'post2')
    
    @comment1 = @post1.comments.create(:title => 'p1c1')
    @comment2 = @post1.comments.create(:title => 'p1c2')
    @comment3 = @post2.comments.create(:title => 'p2c1')
  end
  
  it "should find the normal way" do
    Post.find(@post1.id).should == @post1
  end
  
  it "should find by title" do
    Post.find('post1').should == @post1
  end
  
  it "should find normally in collection" do
    @post1.comments.find(@comment1.id).should == @comment1
  end
  
  it "should still scope correctly" do
    lambda{
      @post1.comments.find(@comment3.id)
    }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
  it "should scope custom finder" do
    @post1.comments.find('p1c1').should == @comment1
  end
  
  it "should raise as expected with custom finder as well" do
    lambda{
      @post1.comments.find('p2c1')
    }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
end
