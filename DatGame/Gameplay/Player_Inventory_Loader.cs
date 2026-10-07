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

            UpdateInventory();
        }

        public void UpdateInventory()
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

                if (slot < inventory.Count)
                {
                    Dictionary item = (Dictionary)inventory[slot];

                    Item_Button_Config conf = (Item_Button_Config)button;
                    conf.Info = item;

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

            }
        }

    }
}
