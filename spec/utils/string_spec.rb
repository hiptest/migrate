describe String do
  context '#as_enum_list' do
    it "transform string into enumerated list" do
      expect('01. blabla 02. blibli 03. bloubl... 04. Plopinette'.as_enum_lines)
        .to eq("01. blabla\n02. blibli\n03. bloubl...\n04. Plopinette")
    end
  end
end