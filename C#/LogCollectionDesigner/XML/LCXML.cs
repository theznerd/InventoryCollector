using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using LogCollectionDesigner.Classes;

namespace LogCollectionDesigner.XML
{
    public class LCXML
    {
        private XmlDocument _xmlDoc;
        
        public LCXML()
        {
            _xmlDoc = new XmlDocument();
            _xmlDoc.AppendChild(_xmlDoc.CreateXmlDeclaration("1.0","UTF-8",null));
            _xmlDoc.AppendChild(_xmlDoc.CreateNode("element", "WMIConfiguration", null));
        }

        public void CreateNamespace(LCNamespace Namespace) 
        {
            XmlNode ns = _xmlDoc.CreateNode("element", "Namespace", null);
            XmlAttribute pathAttribute = _xmlDoc.CreateAttribute("Path");
            pathAttribute.Value = Namespace.Path;
            ns.Attributes.Append(pathAttribute);
            _xmlDoc.DocumentElement.AppendChild(ns);
        }
        public XmlNode ReadNamespace(LCNamespace Namespace) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']");
            return node;
        }
        public void DeleteNamespace(LCNamespace Namespace) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']");
            node.ParentNode.RemoveChild(node);
        }
        public bool FindNamespace(LCNamespace Namespace)
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']");
            return (null == node) ? false : true;
        }

        public void CreateClass(LCNamespace Namespace, LCClass Class) 
        {
            XmlNode cl = _xmlDoc.CreateNode("element", "Class", null);
            XmlAttribute nameAttribute = _xmlDoc.CreateAttribute("Name");
            nameAttribute.Value = Class.Name;
            cl.Attributes.Append(nameAttribute);
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']");
            if(node == null)
            {
                CreateNamespace(Namespace);
                node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']");
            }
            node.AppendChild(cl);
        }
        public XmlNode ReadClass(LCNamespace Namespace, LCClass Class) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']");
            return node;
        }
        public void DeleteClass(LCNamespace Namespace, LCClass Class) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']");
            node.ParentNode.RemoveChild(node);
        }
        public bool FindClass(LCNamespace Namespace, LCClass Class)
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']");
            return (null == node) ? false : true;
        }

        public void CreateProperty(LCNamespace Namespace, LCClass Class, LCClassProperty Property) 
        {
            XmlNode pr = _xmlDoc.CreateNode("element", "Property", null);
            XmlAttribute nameAttribute = _xmlDoc.CreateAttribute("Name");
            nameAttribute.Value = Property.Name;
            pr.Attributes.Append(nameAttribute);
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']");
            if(node == null)
            {
                CreateClass(Namespace, Class);
                node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']");
            }
            node.AppendChild(pr);
        }
        public XmlNode ReadProperty(LCNamespace Namespace, LCClass Class, LCClassProperty Property) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']/Property[@Name='" + Property.Name + "']");
            return node;
        }
        public void DeleteProperty(LCNamespace Namespace, LCClass Class, LCClassProperty Property) 
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']/Property[@Name='" + Property.Name + "']");
            node.ParentNode.RemoveChild(node);
        }
        public bool FindProperty(LCNamespace Namespace, LCClass Class, LCClassProperty Property)
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']/Property[@Name='" + Property.Name + "']");
            return (null == node) ? false : true;
        }
        public bool FindProperty(LCNamespace Namespace, LCClass Class, string PropertyName)
        {
            XmlNode node = _xmlDoc.SelectSingleNode("/WMIConfiguration/Namespace[@Path='" + Namespace.Path + "']/Class[@Name='" + Class.Name + "']/Property[@Name='" + PropertyName + "']");
            return (null == node) ? false : true;
        }

        public void SaveXML(string path)
        {
            // Remove Empty Classes
            XmlNodeList ecs = _xmlDoc.SelectNodes("/WMIConfiguration/Namespace/Class[not(Property)]");
            foreach(XmlNode ec in ecs)
            {
                ec.ParentNode.RemoveChild(ec);
            }
            // Remove Empty Namespaces
            XmlNodeList ens = _xmlDoc.SelectNodes("/WMIConfiguration/Namespace[not(Class)]");
            foreach (XmlNode en in ens)
            {
                en.ParentNode.RemoveChild(en);
            }
            _xmlDoc.Save(path);
        }
        
        public void LoadXML(string path)
        {
            _xmlDoc = new XmlDocument();
            _xmlDoc.Load(path);
        }
    }
}
