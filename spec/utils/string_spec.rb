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

    it 'also work with unicode expressed single quotes' do
      expect("Do this by selecting &#x27;Tech_Checks&#x27;".single_quotes_escaped).to eq %q(Do this by selecting \\'Tech_Checks\\')
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

    it "also works with single quotes expressed as unicode" do
      expect("Do this by selecting &#x27;Tech_Checks&#x27;".single_quotes_replaced).to eq %q(Do this by selecting "Tech_Checks")
    end
  end

  context '#double_quotes_replaced' do
    it "replace double quotes by single quotes" do
      expect(%Q(Say "hello").double_quotes_replaced).to eq %Q(Say 'hello')
    end
  end

  context '#uncapitalize' do
    it "transforms the first letter into downcase" do
      expect('coucou'.uncapitalize).to eq('coucou')
      expect('Coucou'.uncapitalize).to eq('coucou')
    end
  end

  context '#camelize' do
    it "transforms any string into its camelcase form" do
      expect('nous_sommes_mercredi'.camelize).to eq('nousSommesMercredi')
      expect('NOUS_sOMmes_mercreDI'.camelize).to eq('nousSommesMercredi')
    end
  end

  context '#underscore' do
    it "transforms any string into its snakecase form" do
      expect('nousSommesMercredi'.underscore).to eq('nous_sommes_mercredi')
    end
  end
end
