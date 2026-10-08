using Godot;
using System;
using Godot.Collections;

namespace DATGame
{
    public partial class Player_Inventory_Loader : HBoxContainer
    {
        private Main _head;

        private VBoxContainer _abilityinventory;
        private VBoxContainer _combatinventory;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");

            _abilityinventory = GetNode<VBoxContainer>("Ability/Ability List");
            _combatinventory = GetNode<VBoxContainer>("Combat/Combat List");

            GenerateInventory();
        }

        public void GenerateInventory()
        {
            foreach (Node child in (_abilityinventory.GetChildren() + _combatinventory.GetChildren()))
            {
                child.QueueFree();
            }

            PlayerDAO dao = new PlayerDAO();

            Godot.Collections.Array inventory = dao.GetInventory(_head.Account, _head.Room);

            for (int slot = 0; slot < Math.Max(8, inventory.Count); slot++)
            {
                PanelContainer button = (PanelContainer)GD.Load<PackedScene>("res://Gameplay/Item Button.tscn").Instantiate();

                int buttonwidth = (int)((Size.X / 2) * 0.75);
                button.CustomMinimumSize = new Vector2(buttonwidth, (int)(buttonwidth / 1.5));
                button.CustomMaximumSize = button.CustomMinimumSize;

                button.SizeFlagsHorizontal = SizeFlags.ShrinkCenter;

                Item_Button_Config conf = (Item_Button_Config)button;

                Dictionary item = null;

                if (slot < inventory.Count)
                {
                    item = (Dictionary)inventory[slot];

                    if ((bool)item["Combat"] == true)
                    {
                        _combatinventory.AddChild(button);
                    }
                    else
                    {
                        _abilityinventory.AddChild(button);
                    }
                }
                else
                {
                    if (_combatinventory.GetChildCount() >= 4)
                    {
                        _abilityinventory.AddChild(button);
                    }
                    else
                    {
                        _combatinventory.AddChild(button);
                    }
                }

                conf.UpdateContents(item);
            }
        }

        public void UpdateInventory()
        {
            PlayerDAO dao = new PlayerDAO();

            Godot.Collections.Array inventory = dao.GetInventory(_head.Account, _head.Room);

            Godot.Collections.Array abilityinventory = new Godot.Collections.Array();
            Godot.Collections.Array combatinventory = new Godot.Collections.Array();

            foreach (Dictionary ability in inventory)
            {
                if ((bool)ability["Combat"] == true)
                {
                    combatinventory.Add(ability);
                }
                else
                {
                    abilityinventory.Add(ability);
                }
            }

            Godot.Collections.Array combatchildren = (Godot.Collections.Array)_combatinventory.GetChildren();
            Godot.Collections.Array abilitychildren = (Godot.Collections.Array)_abilityinventory.GetChildren();

            for (int slot = 0; slot < combatchildren.Count; slot++)
            {
                Dictionary item = null;

                if (slot < combatinventory.Count)
                {
                    item = (Dictionary)combatinventory[slot];
                }

                Item_Button_Config conf = (Item_Button_Config)combatchildren[slot];
                conf.UpdateContents(item);
            }

            for (int slot = 0; slot < abilitychildren.Count; slot++)
            {
                Dictionary item = null;

                if (slot < abilityinventory.Count)
                {
                    item = (Dictionary)abilityinventory[slot];
                }

                Item_Button_Config conf = (Item_Button_Config)abilitychildren[slot];
                conf.UpdateContents(item);
            }
        }

    }
}
