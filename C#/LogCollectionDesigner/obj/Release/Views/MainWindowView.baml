   M S B A M L   `   `   `  ���� P  LLogCollectionDesigner, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null=#clr-namespace:LogCollectionDesignerLogCollectionDesigner  R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R8clr-namespace:System.ComponentModel;assembly=WindowsBaseSystem.ComponentModel 0    *LogCollectionDesigner.Views.MainWindowView   \ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     @d2http://schemas.microsoft.com/expression/blend/2008     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     H DMahApps.Metro, Version=1.6.5.1, Culture=neutral, PublicKeyToken=null5ma,http://metro.mahapps.com/winfx/xaml/controls  c _MahApps.Metro.IconPacks.Core, Version=3.0.0.0, Culture=neutral, PublicKeyToken=0c0d510f9915137aj fMahApps.Metro.IconPacks.FontAwesome, Version=3.0.0.0, Culture=neutral, PublicKeyToken=0c0d510f9915137a8ip-http://metro.mahapps.com/winfx/xaml/iconpacks   ^ ZCaliburn.Micro.Platform, Version=3.2.0.0, Culture=neutral, PublicKeyToken=8e5891231f2ed21f(calhttp://www.caliburnproject.org  /local#clr-namespace:LogCollectionDesigner  Bscm8clr-namespace:System.ComponentModel;assembly=WindowsBase    � Title$  Log Collector Designer��$	��415��$	��800��$	��800��$	��415��.���  � RowDefinitions �� $
��Auto ��� $
��Auto ��� $
��Auto ��� $��* � � ColumnDefinitions �� $��* ��� $��* �.+���  �� Orientation$ 
Horizontal=�$��2��.+��� -    ��Name$	 New��$	��125��$��10q�.���� $ 
Horizontal=�$��Center=�.+�1  +MahApps.Metro.IconPacks.PackIconFontAwesome     Kind$ 	FileSolid=�$��Center=��� $��Center=�$��14(�$��0q�$��5,0,0,0q�.��	New/Reset�� -   $
 Load��$	��100��$��10q�$��Center=�.���� $ 
Horizontal=�.+�  $ FolderOpenSolid=�$��Center=��� $��Center=�$��14(�$��0q�$��5,0,0,0q�.��Load�� -   $
 Save��$	��100��$��10q�.���� $ 
Horizontal=�.+�  $ 	SaveSolid=�$��Center=��� $��Center=�$��14(�$��0q�$��5,0,0,0q�.��Save�� $ 
Horizontal=�$��Right=�$��2��.+��� $��Segoe UI Light)�$��20(�$��Center=�$+��%WMI Inventory Collector Designer v1.0��  $ 	BookSolid=�$��Center=�$��30��$��30��$��0,0,5,0q��� $ 
Horizontal=�$��5q�$��1��$��2��.+��� $��0,0,5,0q�$��Center=�$��0q�.��
Namespace:�� -    ��Name$ 
Namespaces��$	��300�� �� DisplayMemberPath$
 Path��  Caliburn.Micro.Message   Attach$8 2[Event SelectionChanged] = [Action RefreshClasses]��	 �� 
IsEditable	 .  {��� *CanRefreshNamespaces+�� -   $ RefreshNamespaces��)  #MahApps.Metro.Controls.ButtonHelper
   PreserveTextCase
 . $��5,0,0,0q�.��Refresh Namespaces�� $��2��$��5,0,0,0q�$��0q�.��	Classes�� -    ��Name$ Classes��$��3��$��5q�$��1q�$��Visible=�$; 5[Event SelectionChanged] = [Action RefreshProperties]�� �� SelectedItem ��  �� Path$ SelectedClass� �� Mode$ TwoWay=����� .R��� $ 
Horizontal=�.+���  d� IsThreeState . $7 1[Event Click] = [Action CheckClass($datacontext)]�� d� 	IsChecked �� *
CheckState+ =� ErrorTemplate Z�   Caliburn.Micro.Action   TargetWithoutContext �� *DataContext+ �� RelativeSource ��  �� AncestorType" ���� ���� *Name+�� $��2��$��1��$��5,0,0,0q�$��0q�.��Class Properties�� -   $ 
Properties��$��3��$��1��$��5q�$��1q�$��Visible=����� .R��� $ 
Horizontal=�.+��� $: 4[Event Click] = [Action CheckProperty($datacontext)]�� �� *
CheckState+ �� *DataContext+ �� " ���� ���� *Name+� -    �Name$ LoadingWindowIsVisible�����	#AA000000$��2��$��4��$y�Hidden=�.+��� $ Vertical=�$��Center=�$��Center=�.+�)  #MahApps.Metro.Controls.ProgressRing     IsActive . 
��������� $��Center=�$��20(�
�������.��Please wait...�� -	    ��Name$ ProgressText��$��Center=�$��14(�
�������$��0q�.��Loading Namespaces...