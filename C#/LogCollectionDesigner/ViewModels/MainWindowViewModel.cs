using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Caliburn.Micro;
using System.Management;
using System.IO;
using System.Windows;
using Microsoft.Win32;
using LogCollectionDesigner.XML;

namespace LogCollectionDesigner.ViewModels
{
    public class MainWindowViewModel : PropertyChangedBase
    {
        private LCXML xml;

        public MainWindowViewModel()
        {
            Namespaces = new BindableCollection<Classes.LCNamespace>();
            Classes = new BindableCollection<Classes.LCClass>();
            Properties = new BindableCollection<Classes.LCClassProperty>();
            xml = new LCXML();
            RefreshNamespaces();
        }

        public List<string> GetWmiNamespace(string basePath)
        {
            List<string> namespaces = new List<string>();
            ManagementScope scope = new ManagementScope(basePath);
            scope.Connect();
            ObjectQuery query = new ObjectQuery("select Name from __NAMESPACE");
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection queryCollection = searcher.Get();
            foreach (ManagementObject m in queryCollection)
            {
                string newRoot = basePath + "\\" + (string)m["Name"];
                namespaces.Add(newRoot);
                List<string> newNamespaces = GetWmiNamespace(newRoot);
                foreach (string n in newNamespaces)
                {
                    namespaces.Add(n);
                }
            }
            return namespaces;
        }

        public List<String> GetWmiClasses(string nameSpace)
        {
            List<String> classes = new List<string>();
            ManagementScope scope = new ManagementScope("\\\\.\\" + nameSpace);
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM meta_class WHERE __CLASS LIKE '[^_][^_]%'");
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection queryCollection = searcher.Get();
            foreach(ManagementObject m in queryCollection)
            {
                classes.Add(((ManagementClass)m).Path.ClassName.ToString());
            }
            return classes;
        }

        public List<String> GetWmiProperties(string nameSpace, string className)
        {
            List<String> properties = new List<string>();
            ManagementScope scope = new ManagementScope("\\\\.\\" + nameSpace);
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM meta_class WHERE __CLASS = '" + className + "'");
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection queryCollection = searcher.Get();
            foreach (ManagementObject m in queryCollection)
            {
                foreach(PropertyData p in ((ManagementClass)m).Properties)
                {
                    properties.Add(p.Name);
                }
            }
            return properties;
        }

        private bool _CanRefreshNamespaces;
        public bool CanRefreshNamespaces
        {
            get { return _CanRefreshNamespaces; }
            set
            {
                _CanRefreshNamespaces = value;
                NotifyOfPropertyChange(() => CanRefreshNamespaces);
            }
        }

        public void RefreshNamespaces()
        {
            Task.Run(() =>
            {
                CanRefreshNamespaces = false;
                //ProgressText = "Loading namespaces...";
                //LoadingWindowIsVisible = true;
                Properties.Clear();
                Classes.Clear();
                Namespaces.Clear();
                List<string> result = GetWmiNamespace("\\\\.\\ROOT");
                foreach (string r in result)
                {
                    Namespaces.Add(new Classes.LCNamespace() { Path = r.Replace("\\\\.\\", "") });
                }
                //LoadingWindowIsVisible = false;
                CanRefreshNamespaces = true;
            });
        }

        public void RefreshClasses()
        {
            Task.Run(() =>
            {
                //ProgressText = "Loading classes for " + SelectedNamespace.Path;
                //LoadingWindowIsVisible = true;
                Properties.Clear();
                Classes.Clear();
                try
                {
                    List<string> result = GetWmiClasses(SelectedNamespace.Path);
                    foreach (string r in result)
                    {
                        Classes.LCClass cl = new Classes.LCClass()
                        {
                            CheckState = false,
                            Name = r
                        };
                        List<string> clProperties = GetWmiProperties(SelectedNamespace.Path, r);
                        int selectedPropertiesCount = 0;
                        foreach(string prop in clProperties)
                        {
                            if(xml.FindProperty(SelectedNamespace, cl, prop))
                            {
                                selectedPropertiesCount++;
                            }
                        }
                        if(selectedPropertiesCount == 0){ cl.CheckState = false; }
                        else if(clProperties.Count == selectedPropertiesCount){ cl.CheckState = true; }
                        else{ cl.CheckState = null; }

                        Classes.Add(cl);
                    }
                }
                catch { }
                //LoadingWindowIsVisible = false;
            });
        }

        public void RefreshProperties()
        {
            // Task.Run(() =>
            //{
                //ProgressText = "Loading properties for " + SelectedClass.Name;
                //LoadingWindowIsVisible = true;
                Properties.Clear();
                try
                {
                    List<string> result = GetWmiProperties(SelectedNamespace.Path, SelectedClass.Name);
                    foreach (string r in result)
                    {
                        Classes.LCClassProperty cp = new Classes.LCClassProperty()
                        {
                            CheckState = false,
                            Name = r
                        };
                        if (xml.FindProperty(SelectedNamespace, SelectedClass, cp))
                        {
                            cp.CheckState = true;
                        }
                        Properties.Add(cp);
                    }
                }
                catch { }
                //LoadingWindowIsVisible = false;
            //});
        }

        public void New()
        {
            xml = new LCXML();
            RefreshNamespaces();
        }

        public void Load()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "XML Files (*.xml)|*.xml";
            ofd.DefaultExt = "xml";
            if(ofd.ShowDialog() == true)
            {
                RefreshNamespaces();
                xml.LoadXML(ofd.FileName);
            }
        }

        public void Save()
        {
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.Filter = "XML Files (*.xml)|*.xml";
            sfd.DefaultExt = "xml";
            if(sfd.ShowDialog() == true)
            {
                xml.SaveXML(sfd.FileName);
            }
        }

        public void CheckProperty(Classes.LCClassProperty p)
        {
            // What do when you check a property bruh?
            if(p.CheckState == true)
            {
                // Add Property
                xml.CreateProperty(SelectedNamespace, SelectedClass, p);
            }
            else
            {
                // Remove Property
                xml.DeleteProperty(SelectedNamespace, SelectedClass, p);
            }

            // Set Class Check State
            int propertyCount = 0;
            foreach (Classes.LCClassProperty sp in Properties)
            {
                if (sp.CheckState == true) { propertyCount++; }
            }
            if (propertyCount == Properties.Count) { SelectedClass.CheckState = true; }
            else if (propertyCount > 0) { SelectedClass.CheckState = null; }
            else { SelectedClass.CheckState = false; }
        }

        public void CheckClass(Classes.LCClass c)
        {
            SelectedClass = c;
            if(c.CheckState == null || c.CheckState == false)
            {
                c.CheckState = false;
                foreach(Classes.LCClassProperty sp in Properties)
                {
                    if(sp.CheckState == true)
                    {
                        xml.DeleteProperty(SelectedNamespace, SelectedClass, sp);
                        sp.CheckState = false;
                    }
                }
            }
            else
            {
                foreach(Classes.LCClassProperty sp in Properties)
                {
                    if(sp.CheckState == false)
                    {
                        xml.CreateProperty(SelectedNamespace, SelectedClass, sp);
                        sp.CheckState = true;
                    }
                }
            }
        }

        private Classes.LCNamespace _SelectedNamespace;
        public Classes.LCNamespace SelectedNamespace
        {
            get { return _SelectedNamespace; }
            set
            {
                _SelectedNamespace = value;
                NotifyOfPropertyChange(() => SelectedNamespace);
            }
        }

        private BindableCollection<Classes.LCNamespace> _Namespaces;
        public BindableCollection<Classes.LCNamespace> Namespaces
        {
            get { return _Namespaces; }
            set
            {
                _Namespaces = value;
                NotifyOfPropertyChange(() => Namespaces);
            }
        }

        private Classes.LCClass _SelectedClass;
        public Classes.LCClass SelectedClass
        {
            get { return _SelectedClass; }
            set
            {
                _SelectedClass = value;
                NotifyOfPropertyChange(() => SelectedClass);
            }
        }

        private BindableCollection<Classes.LCClass> _Classes;
        public BindableCollection<Classes.LCClass> Classes
        {
            get { return _Classes; }
            set
            {
                _Classes = value;
                NotifyOfPropertyChange(() => Classes);
            }
        }

        private BindableCollection<Classes.LCClassProperty> _Properties;
        public BindableCollection<Classes.LCClassProperty> Properties
        {
            get { return _Properties; }
            set
            {
                _Properties = value;
                NotifyOfPropertyChange(() => Properties);
            }
        }

        private bool _LoadingWindowIsVisible;
        public bool LoadingWindowIsVisible {
            get { return _LoadingWindowIsVisible; }
            set
            {
                _LoadingWindowIsVisible = value;
                NotifyOfPropertyChange(() => LoadingWindowIsVisible);
            } 
        }

        private string _ProgressText;
        public string ProgressText
        {
            get { return _ProgressText; }
            set
            {
                _ProgressText = value;
                NotifyOfPropertyChange(() => ProgressText);
            }
        }
    }
}
