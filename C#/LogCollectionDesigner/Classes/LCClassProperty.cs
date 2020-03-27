using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Caliburn.Micro;

namespace LogCollectionDesigner.Classes
{
    public class LCClassProperty : PropertyChangedBase
    {
        public string Name { get; set; }
        private bool _CheckState;
        public bool CheckState
        {
            get { return _CheckState; }
            set
            {
                _CheckState = value;
                NotifyOfPropertyChange(() => CheckState);
            }
        }
    }
}
