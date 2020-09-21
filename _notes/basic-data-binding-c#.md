---
layout: note
draft: false
date: 2019-06-17 17:32:00 +0200
author: Victor Hachard
---

## Item.cs

Create the object to insert in the Data Grid.

```c++
namespace XX
{
    public class Item
    {
        //Attributes
        private string name;

        //Getters Setters
        public string Name { get => name; set => name = value; }

        //Constructors
        public Item() {}
        public Item(string name)
        {
          this.Name = name;
        }
    }
}
```

## MainWindow.xaml.cs

Create the Observable Collection to store the Item. Set the Observable Collection in the Data Context.

```c++
namespace XX
{
    public partial class MainWindow : Window
    {
        public ObservableCollection<Item> lstItem = new ObservableCollection<Item>(); //Create

        public MainWindow()
        {
            InitializeComponent();
            DataContext = lstItem; //Set

            //Test
            Item item = new Item();
            item.Name = "Victor";

            lstItem.Add(item);
            //End Test
        }
    }
}
```

## MainWindow.xaml

Create the Data Grid in the xaml and the Window Resources.

```css
<Window x:Class="XX.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:XX"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Window.Resources>
        <CollectionViewSource x:Key="Item" Source="{Binding}"/> /*Bind the Item*/
    </Window.Resources>
    <Grid>
        <DataGrid x:Name="Grid" IsReadOnly="True" AutoGenerateColumns="False" HorizontalAlignment="Left" Height="100" Margin="300,120,0,0" VerticalAlignment="Top" Width="100" HeadersVisibility="Column" ItemsSource="{Binding Source={StaticResource Item}}"> /*Bind the Item to this Data Grid*/
            <DataGrid.Columns>
                <DataGridTextColumn Header="Name" Width="Auto" Binding="{Binding Name}"/> /*Bind the Item Name to this Column*/
            </DataGrid.Columns>
        </DataGrid>
    </Grid>
</Window>
```
