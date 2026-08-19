#pragma once

#include "rive/viewmodel/runtime/viewmodel_instance_runtime.hpp"
#include "rive/viewmodel/viewmodel_instance_value.hpp"
#include "rive/viewmodel/viewmodel_value_dependent.hpp"

namespace rive{

class ViewModelListener: public ViewModelValueDependent {

public:
	ViewModelListener(ViewModelInstanceValueRuntime* instanceValueRuntime, void* zigProp, void* userdata, void(*callback)( void*, void*));
	void addDirt(ComponentDirt dirt, bool recurse) override;

    	void relinkDataBind() override;

	void* m_userdata;
	void* m_zigProp;
	void(*m_callback)(void*, void*);

	
protected:
	ViewModelInstanceValue* m_viewModelInstanceValue = nullptr;
	ViewModelInstanceValueRuntime* m_viewModelInstanceValueRuntime = nullptr;

};

}


