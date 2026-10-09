using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Abilty_Menu_Loader : HBoxContainer
    {
        private Main _head;
        private PlayerDAO _dao = new PlayerDAO();

        private Label _gaugetext;
        private HBoxContainer _abilitybuttons;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
            _gaugetext = GetNode<Label>("lblEnergy");
            _abilitybuttons = GetNode<HBoxContainer>("Ability Buttons");
        }

        public void _ReplenishEnergy()
        {
            _dao.ReplenishEnergy(_head.Account, _head.Room);
            UpdateEnergyGaugeDisplay();
        }

        public void UpdateEnergyGaugeDisplay()
        {
            int energy = _dao.GetEnergy(_head.Account, _head.Room);

            _gaugetext.Text = $"{energy} / 20";
        }

        public void UpdateAbilityButtons()
        {
            Array inventory = _dao.GetInventory(_head.Account, _head.Room);
            Array usables = [];

            foreach (Dictionary ability in inventory)
            {
                if ((int)ability["Cost"] > 0)
                {
                    usables.Add(ability);
                }
            }

            for (int rm = _abilitybuttons.GetChildren().Count; rm > usables.Count; rm--)
            {
                _abilitybuttons.GetChildren()[rm].QueueFree();
            }

            for (int cr = _abilitybuttons.GetChildren().Count; cr < usables.Count; cr++)
            {
                TextureButton abilitybutton = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Ability Button.tscn").Instantiate();
                _abilitybuttons.CallDeferred("add_child", abilitybutton);
            }

            for (int slot = 0; slot < _abilitybuttons.GetChildren().Count; slot++)
            {
                Ability_Button_Config conf = (Ability_Button_Config)_abilitybuttons.GetChildren()[slot];
                conf.UpdateContents((Dictionary)usables[slot]);
            }
        }

    }
}
