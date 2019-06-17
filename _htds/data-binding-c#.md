---
layout: htd
draft: false
date: 2019-06-17 17:32:00 +0200
author: Victor Hachard
---

## Item.cs

Create the object to insert into the DataGrid.

```java
namespace XX
{
    public class Item
    {
        private string name;
        public string Name { get => name; set => name = value; }
    }
}
```

## MainWindow.xaml.cs

Create the Observable Collection to store the Item.

```java
namespace XX
{
    public partial class MainWindow : Window
    {
        public ObservableCollection<Item> lstItem = new ObservableCollection<Item>();

        public MainWindow()
        {
            InitializeComponent();
            DataContext = lstItem;
        }
    }
}
```

## MainWindow.xaml

Create the DataGrid in the xaml and the Window Resources.

```html
<Window x:Class="XX.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:XX"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Window.Resources>
        <CollectionViewSource x:Key="Item" Source="{Binding}"/>
    </Window.Resources>
    <Grid>
        <DataGrid x:Name="Grid" IsReadOnly="True" AutoGenerateColumns="False" ItemsSource="{Binding Source={StaticResource Item}}" HorizontalAlignment="Left" Height="100" Margin="300,120,0,0" VerticalAlignment="Top" Width="100" HeadersVisibility="Column">
            <DataGrid.Columns>
                <DataGridTextColumn Header="Name" Width="Auto" Binding="{Binding Name}"/>
            </DataGrid.Columns>
        </DataGrid>
    </Grid>
</Window>
```
