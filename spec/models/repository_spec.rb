require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository, :type => :model do

  describe "initialize" do
    before(:each) do
      @repo = Repository.new
    end

    it "should properly set default values" do
      expect(@repo.checkout_overwrite?).to be_falsey
      expect(@repo.checkout_description).to match /Please select the desired protocol below to get the URL/
      expect(@repo.allow_subtree_checkout?).to be_falsey
      expect(@repo.checkout_protocols).to eql []
    end
  end

  describe "subtree checkout" do
    before(:each) do
      @svn = Repository::Subversion.new
      @git = Repository::Git.new
    end
    it "should be allowed on subversion" do
      expect(@svn.allow_subtree_checkout?).to eql true
    end
    it "should only be possible if checked" do

    end

    it "should be forbidden on git" do
      expect(@git.allow_subtree_checkout?).to eql false
    end
  end

  describe "extensions" do
    before(:each) do
      @repo = Repository::Subversion.new
      setup_subversion_protocols
    end

    it "should provide protocols" do
      protocols = @repo.checkout_protocols
      expect(protocols[0].protocol).to eql "Subversion"
      expect(protocols[1].protocol).to eql "SVN+SSH"
      expect(protocols[2].protocol).to eql "Root"
    end
  end

  describe "to_xml" do
    let(:repo) { Repository::Subversion.new }

    it "should not have a yaml typed attribute checkout-settings" do
      # using something like nokogiri would be cleaner
      # but I don't want to introduce the dependency

      expect(repo.to_xml.match(/<checkout-settings[^>]*?type=['"]yaml['"].*?>/)).to be_nil
    end
  end
end
