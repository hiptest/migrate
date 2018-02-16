describe String do
  context '#is_plural?' do
    it "return true if self is plural" do
      expect('scenarios'.is_plural?).to be_truthy
    end
    
    it "return false if self is not plural" do
      expect('senario'.is_plural?).not_to be_truthy
    end
  end
  
  context '#as_enum_list' do
    it "transform string into enumerated list" do
      expect('01. blabla 02. blibli 03. bloubl... 04. Plopinette'.as_enum_lines)
        .to eq("01. blabla\n02. blibli\n03. bloubl...\n04. Plopinette")
    end
  end
  
  context '#single_quotes_escaped' do
    it "escape single quotes" do
      expect("Say 'hello'".single_quotes_escaped).to eq %q(Say \\'hello\\')
    end
  end
  
  context '#double_quotes_escaped' do
    it "escape double quotes" do
      expect('Say "hello"'.double_quotes_escaped).to eq "Say \\\"hello\\\""
    end
  end
  
  context '#single_quotes_replaced' do
    it "replace single quotes by double quotes" do
      expect(%q(Say 'hello').single_quotes_replaced).to eq %q(Say "hello")
    end
  end
  
  context '#double_quotes_replaced' do
    it "replace double quotes by single quotes" do
      expect(%Q(Say "hello").double_quotes_replaced).to eq %Q(Say 'hello')
    end
  end
end