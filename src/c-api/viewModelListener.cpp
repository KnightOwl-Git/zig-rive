
#include "viewModelListener.hpp"
#include <cstdio>


using namespace rive;


//todo: destructor 

ViewModelListener::ViewModelListener(ViewModelInstanceValueRuntime* instanceValueRuntime, void* zigProp, void* userdata, void(*callback)(void*, void*)) {
	m_viewModelInstanceValueRuntime = instanceValueRuntime;
	m_userdata = userdata;
	m_zigProp = zigProp;
	m_callback = callback;
	m_viewModelInstanceValue = m_viewModelInstanceValueRuntime->viewModelInstanceValue();
	m_viewModelInstanceValue->ref();
	m_viewModelInstanceValue->addDependent(this);

}
void ViewModelListener::addDirt(ComponentDirt dirt, bool recurse) {
	m_callback(m_zigProp, m_userdata);
	
}

void ViewModelListener::relinkDataBind() {}


