   M S B A M L   `   `   `  ����P  LLogCollectionDesigner, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null=#clr-namespace:LogCollectionDesignerLogCollectionDesigner  5	   	   R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R8clr-namespace:System.ComponentModel;assembly=WindowsBaseSystem.ComponentModel 5
   	   0    *LogCollectionDesigner.Views.MainWindowView   5      \ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   H DMahApps.Metro, Version=1.6.5.1, Culture=neutral, PublicKeyToken=null5ma,http://metro.mahapps.com/winfx/xaml/controls  5   	   c _MahApps.Metro.IconPacks.Core, Version=3.0.0.0, Culture=neutral, PublicKeyToken=0c0d510f9915137aj fMahApps.Metro.IconPacks.FontAwesome, Version=3.0.0.0, Culture=neutral, PublicKeyToken=0c0d510f9915137a8ip-http://metro.mahapps.com/winfx/xaml/iconpacks   5   	   ^ ZCaliburn.Micro.Platform, Version=3.2.0.0, Culture=neutral, PublicKeyToken=8e5891231f2ed21f(calhttp://www.caliburnproject.org  5   	   /local#clr-namespace:LogCollectionDesigner  5	   	   Bscm8clr-namespace:System.ComponentModel;assembly=WindowsBase  5
   	     � Title$  Log Collector Designer��5   	   $	��415��6(   $	��800��65   $	��800��6A   $	��415��6P   .��5      �  � RowDefinitions 5   
   �� 5      $
��Auto �6   �� 5      $
��Auto �6   �� 5      $
��Auto �6   �� 5      $��* �6    � ColumnDefinitions 5   
   �� 5      $��* �6   �� 5      $��* �6   .+�5   
   ��  �� Orientation$ 
Horizontal=�6   $��2��6.   .+�5      �� -   5         ��Name$	 New��5      $	��125��6"   $��10q�6.   .��5      �� $ 
Horizontal=�6   $��Center=�66   .+�5      1  +MahApps.Metro.IconPacks.PackIconFontAwesome     Kind$ 	FileSolid=�6-   $��Center=�6>   �� 5      $��Center=�6   $��14(�67   $��0q�6E   $��5,0,0,0q�6Q   .��6b   	New/Reset6m   5      5      �� 5      -   5        $
 Load��5      $	��100��6#   $��10q�6/   $��Center=�6;   .��5       �� $ 
Horizontal=�6   .+�5!        $ FolderOpenSolid=�6-   $��Center=�6D   �� 5"      $��Center=�6   $��14(�67   $��0q�6E   $��5,0,0,0q�6Q   .��6b   Load6h   5#      5$      �� 5%      -   5        $
 Save��5%      $	��100��6#   $��10q�6/   .��5&      �� $ 
Horizontal=�6   .+�5'        $ 	SaveSolid=�6-   $��Center=�6>   �� 5(      $��Center=�6   $��14(�67   $��0q�6E   $��5,0,0,0q�6Q   .��6b   Save6h   5)      5*      5+      �� 5,   
   $ 
Horizontal=�6   $��Right=�6.   $��2��6J   .+�5-      �� $��Segoe UI Light)�6   $��20(�60   $��Center=�6>   .��6Y   Log Collector Designer v1.06v     5/      $ 	BookSolid=�6%   $��Center=�66   $��30��6Q   $��30��6]   $��0,0,5,0q�6h   50      �� 51   
   $ 
Horizontal=�6   $��5q�6.   $��1��69   $��2��6F   .+�52      �� $��0,0,5,0q�6   $��Center=�6%   $��0q�6@   .��6L   
Namespace:6X   �� 53      -   5         ��Name$ 
Namespaces��53      $	��300��6+    �� DisplayMemberPath$
 Path��67     Caliburn.Micro.Message   Attach$8 2[Event SelectionChanged] = [Action RefreshClasses]��6P   	 �� 
IsEditable	 .  {�6�   �� *CanRefreshNamespaces+�� 54      -   5        $ RefreshNamespaces��54      )  #MahApps.Metro.Controls.ButtonHelper
   PreserveTextCase
 . $��5,0,0,0q�6X   .��6i   Refresh Namespaces6}   55      �� 56   
   $��2��6   $��5,0,0,0q�6   $��0q�6.   .��6:   	Classes6C   �� 57   
   -   5         ��Name$ Classes��57   *   $��3��6   $��5q�6   $��1q�6;   $��Visible=�6�   $; 5[Event SelectionChanged] = [Action RefreshProperties]��6�    �� SelectedItem 6O   ��  �� Path$ SelectedClass� �� Mode$ TwoWay=���58      �� 59      .R�5:      �� $ 
Horizontal=�6!   .+�5;      ��  d� IsThreeState . $7 1[Event Click] = [Action CheckClass($datacontext)]��6|    d� 	IsChecked 67   �� *
CheckState+ =� ErrorTemplate 6X   Z�   Caliburn.Micro.Action   TargetWithoutContext 6�   �� *DataContext+ �� RelativeSource ��  �� AncestorType" ���� 5<      ��6    �� *Name+5=      5>      5@      �� 5A   
   $��2��6   $��1��6   $��5,0,0,0q�6-   $��0q�6>   .��6J   Class Properties6\   �� 5B   
   -   5        $ 
Properties��5B   :   $��3��6   $��1��6   $��5q�6/   $��1q�6N   $��Visible=�6b   ��5C      �� 5D      .R�5E      �� $ 
Horizontal=�6!   .+�5F      �� $: 4[Event Click] = [Action CheckProperty($datacontext)]��6D    6#   �� *
CheckState+ 6�   �� *DataContext+ �� " ���� 5G      ��6    �� *Name+5H      5I      5K      � 5L   
   -   5         �Name$ LoadingWindowIsVisible��5L      ���	#AA000000$��2��6F   $��4��6Z   $y�Hidden=�6k   .+�5M      �� $ Vertical=�6   $��Center=�60   $��Center=�6K   .+�5N      )  #MahApps.Metro.Controls.ProgressRing     IsActive . 
�������62   �� 5O      $��Center=�6   $��20(�65   
�������.��6V   Please wait...6f   �� 5P      -	   5         ��Name$ ProgressText��5P      $��Center=�6.   $��14(�6K   
�������$��0q�6l   .��6x   Loading Namespaces...6�   5Q      5R      5S      5T      