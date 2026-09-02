
#include "viewModelListener.hpp"
#include "rive/viewmodel/viewmodel_instance_trigger.hpp"
#include <cstdio>

using namespace rive;

// todo: destructor

ViewModelListener::ViewModelListener(
    ViewModelInstanceValueRuntime *instanceValueRuntime, void *zigProp,
    void *userdata, void (*callback)(void *, void *)) {
  m_viewModelInstanceValueRuntime = instanceValueRuntime;
  m_userdata = userdata;
  m_zigProp = zigProp;
  m_callback = callback;
  m_viewModelInstanceValue =
      m_viewModelInstanceValueRuntime->viewModelInstanceValue();
  m_viewModelInstanceValue->ref();
  m_viewModelInstanceValue->addDependent(this);
}
void ViewModelListener::addDirt(ComponentDirt dirt, bool recurse) {
	//prevent trigger properties from triggering twice
  if (m_viewModelInstanceValue->is<rive::ViewModelInstanceTrigger>()) {
    if (m_viewModelInstanceValue->as<rive::ViewModelInstanceTrigger>()
            ->propertyValue() == 1) {
      m_callback(m_zigProp, m_userdata);
    }
  } else {
    m_callback(m_zigProp, m_userdata);
  }
}

void ViewModelListener::relinkDataBind() {}
