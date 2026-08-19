#include "rive/animation/state_machine_instance.hpp"
#include "rive/artboard.hpp"
#include "rive/factory.hpp"
#include "rive/file.hpp"
#include "rive/math/mat2d.hpp"
#include "rive/refcnt.hpp"
#include "rive/renderer/gpu.hpp"
#include "rive/renderer/render_context.hpp"
#include "rive/renderer/render_target.hpp"
#include "rive/renderer/rive_renderer.hpp"
#include "rive/span.hpp"
#include "rive/viewmodel/runtime/viewmodel_instance_artboard_runtime.hpp"
#include "rive/viewmodel/runtime/viewmodel_instance_list_runtime.hpp"
#include "rive/viewmodel/runtime/viewmodel_instance_number_runtime.hpp"
#include "rive/viewmodel/runtime/viewmodel_instance_runtime.hpp"
#include "rive/viewmodel/runtime/viewmodel_runtime.hpp"
#include "rive/viewmodel/viewmodel_instance.hpp"
#include "rive/viewmodel/viewmodel_instance_color.hpp"
#include "rive/viewmodel/viewmodel_instance_number.hpp"
#include "rive/viewmodel/viewmodel_instance_trigger.hpp"
#include "rive/viewmodel/viewmodel_instance_value.hpp"
#include "utils/no_op_factory.hpp"
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <sys/types.h>
#include <xlocale/_stdio.h>

#include "riveWrapper.h"

struct Rive_File : public rive::File {

  using rive::File::import;
};

// TODO: Can I put everything in header file?
// TODO: Figure out memory management

extern "C" {

//
Rive_File *rive_file_import(const uint8_t *data, size_t size,
                            Rive_Factory *factory,
                            Rive_ImportResult *out_result) {

  rive::Span<const uint8_t> data_span(data, size);
  rive::Factory *cpp_factory = reinterpret_cast<rive::Factory *>(factory);
  rive::ImportResult cpp_result;

  // rive::file

  rive::rcp<rive::File> file =
      rive::File::import(data_span, cpp_factory, &cpp_result);

  if (out_result) {
    *out_result = static_cast<Rive_ImportResult>(cpp_result);
  }
  if (!file || cpp_result != rive::ImportResult::success) {
    return nullptr;
  }

  // unwrap from rcp
  return reinterpret_cast<Rive_File *>(file.release());
}

void rive_file_release(Rive_File *file) {
  if (file) {

    // rewrap into rcp
    // rive::rcp<rive::File> file_to_clean(reinterpret_cast<rive::File*>(file));
    reinterpret_cast<rive::File *>(file)->unref();
  }
}

Rive_ArtboardInstance *rive_file_artboardDefault(Rive_File *file) {

  rive::File *cpp_file = reinterpret_cast<rive::File *>(file);
  return reinterpret_cast<Rive_ArtboardInstance *>(
      cpp_file->artboardDefault().release());
};

void *rive_file_getBindableArtboardNamed(Rive_File *file, const char *name) {
  rive::File *cpp_file = reinterpret_cast<rive::File *>(file);

  return cpp_file->bindableArtboardNamed(name).release();
}

void *rive_file_getBindableArtboardDefault(Rive_File *file) {
  rive::File *cpp_file = reinterpret_cast<rive::File *>(file);

  return cpp_file->bindableArtboardDefault().release();
}

Rive_ViewModelRuntime *
rive_defaultArtboardViewModel(Rive_File *file,
                              Rive_ArtboardInstance *artboard) {
  auto *cpp_artboard = reinterpret_cast<rive::ArtboardInstance *>(artboard);
  auto *cpp_file = reinterpret_cast<rive::File *>(file);
  return reinterpret_cast<Rive_ViewModelRuntime *>(
      cpp_file->defaultArtboardViewModel(cpp_artboard));
}
Rive_ViewModelInstance *rive_createViewModelInstance(Rive_File *file,
                                                     const char *name) {
  auto *cpp_file = reinterpret_cast<rive::File *>(file);
  auto vmi = cpp_file->createViewModelInstance(name);
  return reinterpret_cast<Rive_ViewModelInstance *>(vmi.release());
}

// headless factory for testing
Rive_Factory *rive_factory_createHeadless() {
  return reinterpret_cast<Rive_Factory *>(new rive::NoOpFactory());
}

Rive_ViewModelInstance *rive_createDefaultViewModelInstanceFromArtboard(
    Rive_File *self, Rive_ArtboardInstance *artboard) {
  auto *cpp_artboard = reinterpret_cast<rive::ArtboardInstance *>(artboard);
  auto *cpp_file = reinterpret_cast<rive::File *>(self);
  return reinterpret_cast<Rive_ViewModelInstance *>(
      cpp_file->createDefaultViewModelInstance(cpp_artboard).release());
}

// rive::BindableArtboard

Rive_ArtboardInstance *rive_bindableArtboardGetArtboard(void *bindable) {
  auto *cpp_ab = reinterpret_cast<rive::BindableArtboard *>(bindable);

  return reinterpret_cast<Rive_ArtboardInstance *>(cpp_ab->artboard());
}

// rive::ArtboardInstance
size_t rive_artboard_stateMachineCount(Rive_ArtboardInstance *artboard) {
  if (!artboard)
    return 0;

  rive::ArtboardInstance *cpp_artboard =
      reinterpret_cast<rive::ArtboardInstance *>(artboard);
  return cpp_artboard->stateMachineCount();
}

Rive_StateMachineInstance *
rive_artboard_defaultStateMachine(Rive_ArtboardInstance *artboard) {
  if (!artboard)
    return nullptr;

  rive::ArtboardInstance *cpp_artboard =
      reinterpret_cast<rive::ArtboardInstance *>(artboard);
  return reinterpret_cast<Rive_StateMachineInstance *>(
      cpp_artboard->defaultStateMachine().release());
}

Rive_StateMachineInstance *
rive_artboard_stateMachineAt(Rive_ArtboardInstance *artboard, size_t index) {
  if (!artboard)
    return nullptr;

  rive::ArtboardInstance *cpp_artboard =
      reinterpret_cast<rive::ArtboardInstance *>(artboard);
  return reinterpret_cast<Rive_StateMachineInstance *>(
      cpp_artboard->stateMachineAt(index).release());
}

void Rive_ArtboardReset(Rive_ArtboardInstance *artboard) {

  rive::ArtboardInstance *cpp_artboard =
      reinterpret_cast<rive::ArtboardInstance *>(artboard);

  cpp_artboard->reset();
}

void rive_artboardSetWidth(Rive_ArtboardInstance *artboard, float width) {
  reinterpret_cast<rive::ArtboardInstance *>(artboard)->width(width);
}
void rive_artboardSetHeight(Rive_ArtboardInstance *artboard, float height) {
  reinterpret_cast<rive::ArtboardInstance *>(artboard)->height(height);
}

void rive_artboardBindViewModelInstance(Rive_ArtboardInstance *artboard,
                                        Rive_ViewModelInstanceRuntime *vmi) {
  auto *cpp_artboard = reinterpret_cast<rive::ArtboardInstance *>(artboard);
  auto cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi)->instance();
  cpp_artboard->bindViewModelInstance(cpp_vmi);
}

// rive::stateMachineInstance
void rive_SMIadvanceAndApply(Rive_StateMachineInstance *sm, float secs) {
  if (sm) {
    rive::StateMachineInstance *cpp_smi =
        reinterpret_cast<rive::StateMachineInstance *>(sm);
    cpp_smi->advanceAndApply(secs);
  }
}

void rive_SMIdraw(Rive_StateMachineInstance *sm, Rive_RiveRenderer *renderer) {
  if (sm) {
    rive::StateMachineInstance *cpp_smi =
        reinterpret_cast<rive::StateMachineInstance *>(sm);
    rive::Renderer *cpp_renderer = reinterpret_cast<rive::Renderer *>(renderer);
    cpp_smi->draw(cpp_renderer);
  }
}
void rive_stateMachineBindViewModelInstance(Rive_StateMachineInstance *smi,
                                            Rive_ViewModelInstance *vmi) {
  auto *cpp_smi = reinterpret_cast<rive::StateMachineInstance *>(smi);
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(vmi);
  rive::rcp<rive::ViewModelInstance> cpp_vmi_rcp(cpp_vmi);
  cpp_smi->bindViewModelInstance(cpp_vmi_rcp);
}

void rive_pointerDown(Rive_StateMachineInstance *self, float x, float y) {
  auto *cpp_smi = reinterpret_cast<rive::StateMachineInstance *>(self);
  cpp_smi->pointerDown({x, y});
}

void rive_pointerUp(Rive_StateMachineInstance *self, float x, float y) {
  auto *cpp_smi = reinterpret_cast<rive::StateMachineInstance *>(self);
  cpp_smi->pointerUp({x, y});
}

// TODO: Maybe use Vec2D instaed of float x and y?
void rive_pointerMove(Rive_StateMachineInstance *self, float x, float y) {
  auto *cpp_smi = reinterpret_cast<rive::StateMachineInstance *>(self);
  cpp_smi->pointerMove({x, y});
}

// rive::renderContext
void rive_contextBeginFrame(Rive_RenderContext *context,
                            Rive_FrameDescriptor fd) {
  if (context) {
    auto *cpp_context = reinterpret_cast<rive::gpu::RenderContext *>(context);

    cpp_context->beginFrame({
        .renderTargetWidth = fd.render_target_width,
        .renderTargetHeight = fd.render_target_height,
        .loadAction = rive::gpu::LoadAction::clear,
        .clearColor = fd.clear_color,
    });
  }
}

void rive_contextFlush(Rive_RenderContext *context,
                       Rive_FlushResources *flush) {
  if (context) {
    rive::gpu::RenderContext *cpp_context =
        reinterpret_cast<rive::gpu::RenderContext *>(context);

    cpp_context->flush(
        {.renderTarget =
             reinterpret_cast<rive::gpu::RenderTarget *>(flush->renderTarget),
         .externalCommandBuffer = flush->externalCommandBuffer});
  }
}

Rive_RiveRenderer *rive_getRendererFromContext(Rive_RenderContext *context) {
  rive::gpu::RenderContext *cpp_context =
      reinterpret_cast<rive::gpu::RenderContext *>(context);
  rive::RiveRenderer *renderer = new rive::RiveRenderer(cpp_context);
  return reinterpret_cast<Rive_RiveRenderer *>(renderer);
}

Rive_Factory *rive_contextToFactory(Rive_RenderContext *context) {
  return reinterpret_cast<Rive_Factory *>(context);
}

// rive::riveRenderer

void rive_rendererSave(Rive_RiveRenderer *renderer) {

  rive::RiveRenderer *cpp_renderer =
      reinterpret_cast<rive::RiveRenderer *>(renderer);
  cpp_renderer->save();
}

void rive_rendererRestore(Rive_RiveRenderer *renderer) {

  rive::RiveRenderer *cpp_renderer =
      reinterpret_cast<rive::RiveRenderer *>(renderer);
  cpp_renderer->restore();
}

// TODO: temporary: this is too high level for this api. need to implement
// transform function

void rive_rendererDPIScale(Rive_RiveRenderer *renderer, float dpiScale) {
  auto *cpp_renderer = reinterpret_cast<rive::RiveRenderer *>(renderer);
  cpp_renderer->transform(rive::Mat2D::fromScale(dpiScale, dpiScale));
}

// stub
void rive_rendererAlign(Rive_RiveRenderer *renderer, Rive_Fit *fit,
                        Rive_Alignment *alignment, float scaleFactor) {

  // rive::Alignment cpp_alignment = static_cast<rive::Alignment>(alignment);
  rive::RiveRenderer *cpp_renderer =
      reinterpret_cast<rive::RiveRenderer *>(renderer);
  // cpp_renderer->align();
  cpp_renderer->save();
}
void rive_freeRenderer(Rive_RiveRenderer *renderer) {
  delete reinterpret_cast<rive::RiveRenderer *>(renderer);
}

// rive::gpu::RenderTarget
int rive_renderTargetGetWidth(void *target) {
  auto *cpp_target = static_cast<rive::gpu::RenderTarget *>(target);
  return cpp_target->width();
}

int rive_renderTargetGetHeight(void *target) {
  auto *cpp_target = static_cast<rive::gpu::RenderTarget *>(target);
  return cpp_target->height();
}

// rive::ViewModelRuntime

Rive_ViewModelInstanceRuntime *
rive_createDefaultVMInstance(Rive_ViewModelRuntime *vm) {
  auto *cpp_vm = reinterpret_cast<rive::ViewModelRuntime *>(vm);
  return reinterpret_cast<Rive_ViewModelInstanceRuntime *>(
      cpp_vm->createDefaultInstance().release());
}

// rive::ViewModelInstanceRuntime

Rive_ViewModelInstance *
rive_getViewModelInstance(Rive_ViewModelInstanceRuntime *vmi) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  rive::rcp<rive::ViewModelInstanceRuntime> cpp_vmi_rcp(cpp_vmi);

  return reinterpret_cast<Rive_ViewModelInstance *>(
      cpp_vmi_rcp->instance().release());
}

void *rive_VMIgetProperty(Rive_ViewModelInstanceRuntime *vmi,
                          const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->property(path);
}

// VIEW MODEL PROPERTY DATA TYPES

// NUMBER
void *rive_VMIgetPropertyNumber(Rive_ViewModelInstanceRuntime *vmi,
                                const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  if (!cpp_vmi) {
    return nullptr;
  }
  return cpp_vmi->propertyNumber(path);
}

float rive_VMINumberGetValue(void *prop) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceNumberRuntime *>(prop);
  return cpp_prop->value();
}

void rive_VMINumberSetValue(void *prop, float new_value) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceNumberRuntime *>(prop);
  cpp_prop->value(new_value);
}
void rive_VMINumberRegisterCallback(void *prop, void (*callback)()) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceNumberRuntime *>(prop);
  auto instance_value =
      cpp_prop->viewModelInstanceValue()->as<rive::ViewModelInstanceNumber>();
  auto cpp_callback = reinterpret_cast<rive::ViewModelNumberChanged>(callback);
  instance_value->onChanged(cpp_callback);
}

// BOOLEAN

void *rive_VMIgetPropertyBoolean(Rive_ViewModelInstanceRuntime *vmi,
                                 const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyBoolean(path);
}

bool rive_VMIBooleanGetValue(void *prop) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceBooleanRuntime *>(prop);
  return cpp_prop->value();
}

void rive_VMIBooleanSetValue(void *prop, bool new_value) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceBooleanRuntime *>(prop);
  cpp_prop->value(new_value);
}
void rive_VMIBooleanRegisterCallback(void *prop, void (*callback)()) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceBooleanRuntime *>(prop);
  auto instance_value =
      cpp_prop->viewModelInstanceValue()->as<rive::ViewModelInstanceBoolean>();
  auto cpp_callback = reinterpret_cast<rive::ViewModelBooleanChanged>(callback);
  instance_value->onChanged(cpp_callback);
}

// STRING
void *rive_VMIgetPropertyString(Rive_ViewModelInstanceRuntime *vmi,
                                const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyString(path);
}

const char *rive_VMIStringGetValue(void *prop) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceStringRuntime *>(prop);
  return cpp_prop->value().c_str();
}

void rive_VMIStringSetValue(void *prop, const char *new_value) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceStringRuntime *>(prop);
  cpp_prop->value(new_value);
}
void rive_VMIStringRegisterCallback(void *prop, void (*callback)()) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceStringRuntime *>(prop);
  auto instance_value = cpp_prop->viewModelInstanceValue();
  auto string_prop =
      reinterpret_cast<rive::ViewModelInstanceString *>(instance_value);
  auto cpp_callback = reinterpret_cast<rive::ViewModelStringChanged>(callback);
  string_prop->onChanged(cpp_callback);
}

// COLOR

void *rive_VMIgetPropertyColor(Rive_ViewModelInstanceRuntime *vmi,
                               const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyColor(path);
}

int rive_VMIColorGetValue(void *prop) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceColorRuntime *>(prop);
  return cpp_prop->value();
}

void rive_VMIColorSetValue(void *prop, int new_value) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceColorRuntime *>(prop);
  cpp_prop->value(new_value);
}
void rive_VMIColorRegisterCallback(void *prop, void (*callback)()) {
  auto cpp_prop = reinterpret_cast<rive::ViewModelInstanceColorRuntime *>(prop);
  auto instance_value = cpp_prop->viewModelInstanceValue();
  auto color_prop =
      reinterpret_cast<rive::ViewModelInstanceColor *>(instance_value);
  auto cpp_callback = reinterpret_cast<rive::ViewModelColorChanged>(callback);
  color_prop->onChanged(cpp_callback);
}

// TRIGGER

void *rive_VMIgetPropertyTrigger(Rive_ViewModelInstanceRuntime *vmi,
                                 const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyTrigger(path);
}

void rive_VMITriggerTrigger(void *prop) {
  auto *cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceTriggerRuntime *>(prop);
  cpp_prop->trigger();
}

void rive_VMITriggerRegisterCallback(void *prop, void (*callback)()) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceTriggerRuntime *>(prop);
  auto instance_value =
      cpp_prop->viewModelInstanceValue()->as<rive::ViewModelInstanceTrigger>();
  auto cpp_callback = reinterpret_cast<rive::ViewModelTriggerChanged>(callback);
  instance_value->onChanged(cpp_callback);
}

// ARTBOARD
void *rive_VMIgetPropertyArtboard(Rive_ViewModelInstanceRuntime *vmi,
                                  const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyArtboard(path);
}

const char *rive_VMIArtboardGetName(void *prop) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceArtboardRuntime *>(prop);
  return cpp_prop->artboardName().c_str();
}

void rive_VMIArtboardSetValue(void *prop, void *new_value) {
  auto cpp_prop =
      reinterpret_cast<rive::ViewModelInstanceArtboardRuntime *>(prop);
  rive::rcp<rive::BindableArtboard> cpp_ab_rcp(
      reinterpret_cast<rive::BindableArtboard *>(new_value));

  cpp_prop->value(cpp_ab_rcp);
}

// ENUM

void *rive_VMIgetPropertyEnum(Rive_ViewModelInstanceRuntime *vmi,
                              const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyEnum(path);
}

const char *rive_VMIEnumGetValue(void *prop) {
  auto *cpp_prop = reinterpret_cast<rive::ViewModelInstanceEnumRuntime *>(prop);
  return cpp_prop->value().c_str();
}

void rive_VMIEnumSetValue(void *prop, const char *new_value) {
  auto *cpp_prop = reinterpret_cast<rive::ViewModelInstanceEnumRuntime *>(prop);
  cpp_prop->value(new_value);
}

int rive_VMIEnumGetValueIndex(void *prop) {
  auto *cpp_prop = reinterpret_cast<rive::ViewModelInstanceEnumRuntime *>(prop);
  return cpp_prop->valueIndex();
}
void rive_VMIEnumSetValueIndex(void *prop, int new_value) {
  auto *cpp_prop = reinterpret_cast<rive::ViewModelInstanceEnumRuntime *>(prop);
  cpp_prop->valueIndex(new_value);
}

const char *rive_VMIEnumGetType(void *prop) {
  auto *cpp_prop = reinterpret_cast<rive::ViewModelInstanceEnumRuntime *>(prop);
  return cpp_prop->enumType().c_str();
}

// LIST

void *rive_VMIgetPropertyList(Rive_ViewModelInstanceRuntime *vmi,
                              const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return cpp_vmi->propertyList(path);
}

Rive_ViewModelInstanceRuntime *rive_VMIListGetInstanceAt(void *self,
                                                         int index) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  return reinterpret_cast<Rive_ViewModelInstanceRuntime *>(
      cpp_list->instanceAt(index).release());
}

void rive_VMIListAddInstance(void *self,
                             Rive_ViewModelInstanceRuntime *instance) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  auto cpp_instance =
      reinterpret_cast<rive::ViewModelInstanceRuntime *>(instance);
  cpp_list->addInstance(cpp_instance);
}

void rive_VMIListAddInstanceAt(void *self,
                               Rive_ViewModelInstanceRuntime *instance,
                               int index) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  auto cpp_instance =
      reinterpret_cast<rive::ViewModelInstanceRuntime *>(instance);
  cpp_list->addInstanceAt(cpp_instance, index);
}

void rive_VMIListRemoveInstance(void *self,
                                Rive_ViewModelInstanceRuntime *instance) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  auto cpp_instance =
      reinterpret_cast<rive::ViewModelInstanceRuntime *>(instance);
  cpp_list->removeInstance(cpp_instance);
}

void rive_VMIListRemoveInstanceAt(void *self, int index) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  cpp_list->removeInstanceAt(index);
}

void rive_VMIListRemoveAll(void *self) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  cpp_list->removeAllInstances();
}

void rive_VMIListSwap(void *self, int a, int b) {
  auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceListRuntime *>(self);
  cpp_list->swap(a, b);
}

// NESTED VIEW MODEL

Rive_ViewModelInstanceRuntime *
rive_VMIgetPropertyViewModel(Rive_ViewModelInstanceRuntime *vmi,
                             const char *path) {
  auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstanceRuntime *>(vmi);
  return reinterpret_cast<Rive_ViewModelInstanceRuntime *>(
      cpp_vmi->propertyViewModel(path).release());
}

// OLDER VERSION
//
//  // rive::viewModelInstance
//  Rive_VMI_Number *rive_getVMINumber(Rive_ViewModelInstance *self,
//                                     const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//      auto vmiNumber = propValue->as<rive::ViewModelInstanceNumber>();
//      return reinterpret_cast<Rive_VMI_Number *>(vmiNumber);
//
//    } else {
//      return nullptr;
//    }
//  }
//
//  //TODO: See if I can make a generic get VMI property function
//
//  Rive_ViewModelInstance *rive_getVMIFromNumber(Rive_VMI_Number *self) {
//    auto *cpp_number = reinterpret_cast<rive::ViewModelInstanceNumber*>(self);
//    auto *cpp_vmi = cpp_number->viewModelInstance();
//    return reinterpret_cast<Rive_ViewModelInstance*>(cpp_vmi);
//  }
//
//  Rive_VMI_Boolean *rive_getVMIBoolean(Rive_ViewModelInstance *self,
//                                       const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto ret =
//    cpp_vmi->propertyValue(name)->as<rive::ViewModelInstanceBoolean>();
//
//    return reinterpret_cast<Rive_VMI_Boolean *>(ret);
//  }
//
//  Rive_VMI_Trigger *rive_getVMITrigger(Rive_ViewModelInstance *self,
//                                       const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//
//      auto ret = propValue->as<rive::ViewModelInstanceTrigger>();
//      return reinterpret_cast<Rive_VMI_Trigger *>(ret);
//    } else {
//      return nullptr;
//    }
//
//  }
//
//  Rive_VMI_Color *rive_getVMIColor(Rive_ViewModelInstance *self,
//                                   const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//      auto vmiColor = propValue->as<rive::ViewModelInstanceColor>();
//      return reinterpret_cast<Rive_VMI_Color *>(vmiColor);
//
//    } else {
//      return nullptr;
//    }
//  }
//
//  Rive_VMI_Enum *rive_getVMIEnum(Rive_ViewModelInstance *self,
//                                 const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//      auto vmiEnum = propValue->as<rive::ViewModelInstanceEnum>();
//      return reinterpret_cast<Rive_VMI_Enum *>(vmiEnum);
//
//    } else {
//      return nullptr;
//    }
//  }
//
//  Rive_VMI_ViewModel *rive_getVMIViewModel(Rive_ViewModelInstance *self,
//                                 const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//      auto vmiViewModel = propValue->as<rive::ViewModelInstanceViewModel>();
//      return reinterpret_cast<Rive_VMI_ViewModel
//      *>(vmiViewModel->viewModelInstance());
//
//    } else {
//      return nullptr;
//    }
//  }
//
//  Rive_VMI_List *rive_getVMIList(Rive_ViewModelInstance *self,
//                                 const char *name) {
//    auto *cpp_vmi = reinterpret_cast<rive::ViewModelInstance *>(self);
//    auto propValue = cpp_vmi->propertyValue(name);
//    if (propValue) {
//      auto vmiList = propValue->as<rive::ViewModelInstanceList>();
//      return reinterpret_cast<Rive_VMI_List *>(vmiList);
//
//    } else {
//      return nullptr;
//    }
//  }
//
//  Rive_VMI_ListItem* rive_VMIlistItemInit(Rive_ViewModelInstance *self) {
//    rive::rcp<rive::ViewModelInstance>
//    cpp_VMInstance(reinterpret_cast<rive::ViewModelInstance*>(self)); auto
//    cpp_VMIListRCP = rive::make_rcp<rive::ViewModelInstanceListItem>();
//    cpp_VMIListRCP->viewModelInstance(cpp_VMInstance);
//    return reinterpret_cast<Rive_VMI_ListItem*>(cpp_VMIListRCP.release());
//
//  }

// // View Model Property setters and getters
//
//
// float rive_getVMINumberValue(Rive_VMI_Number *self) {
//   auto *cpp_num = reinterpret_cast<rive::ViewModelInstanceNumber *>(self);
//   return cpp_num->propertyValue();
// }
//
// void rive_setVMINumberValue(Rive_VMI_Number *self, float value) {
//   auto *cpp_num = reinterpret_cast<rive::ViewModelInstanceNumber *>(self);
//   cpp_num->propertyValue(value);
// }
//
// void rive_VMINumberSetCallback(Rive_VMI_Number *self, void (*callback)()) {
//   auto *cpp_number = reinterpret_cast<rive::ViewModelInstanceNumber *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelNumberChanged>(callback);
//
//   cpp_number->onChanged(cpp_callback);
//
// }
//
// uint32_t rive_getVMIColorValue(Rive_VMI_Color *self) {
//   auto *cpp_color = reinterpret_cast<rive::ViewModelInstanceColor *>(self);
//   return cpp_color->propertyValue();
// }
//
// void rive_setVMIColorValue(Rive_VMI_Color *self, uint32_t value) {
//   auto *cpp_color = reinterpret_cast<rive::ViewModelInstanceColor *>(self);
//   cpp_color->propertyValue(value);
// }
//
// void rive_VMIColorSetCallback(Rive_VMI_Color *self, void (*callback)()) {
//   auto *cpp_color = reinterpret_cast<rive::ViewModelInstanceColor *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelColorChanged>(callback);
//
//   cpp_color->onChanged(cpp_callback);
//
// }
//
// uint32_t rive_getVMIEnumValue(Rive_VMI_Enum *self) {
//   auto *cpp_enum = reinterpret_cast<rive::ViewModelInstanceEnum *>(self);
//   return cpp_enum->propertyValue();
// }
//
// void rive_setVMIEnumValue(Rive_VMI_Enum *self, uint32_t value) {
//   auto *cpp_enum = reinterpret_cast<rive::ViewModelInstanceEnum *>(self);
//   cpp_enum->propertyValue(value);
// }
//
// void rive_VMIEnumSetCallback(Rive_VMI_Enum *self, void (*callback)()) {
//   auto *cpp_enum = reinterpret_cast<rive::ViewModelInstanceEnum *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelEnumChanged>(callback);
//
//   cpp_enum->onChanged(cpp_callback);
//
// }
// Rive_VMI_ListItem* rive_getVMIListItem(Rive_VMI_List *self, uint32_t index) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   return
//   reinterpret_cast<Rive_VMI_ListItem*>(cpp_list->item(index).release());
// }
// void rive_VMIListAddItem(Rive_VMI_List *self, Rive_VMI_ListItem* item) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   rive::rcp<rive::ViewModelInstanceListItem>
//   cpp_item(reinterpret_cast<rive::ViewModelInstanceListItem * >(item));
//   cpp_list->addItem(cpp_item);
//
// }
// void rive_VMIListAddItemAt(Rive_VMI_List *self, Rive_VMI_ListItem* item, int
// index) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   rive::rcp<rive::ViewModelInstanceListItem>
//   cpp_item(reinterpret_cast<rive::ViewModelInstanceListItem * >(item));
//   cpp_list->addItemAt(cpp_item, index);
//
// }
// void rive_VMIListRemoveAll(Rive_VMI_List *self) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//
//   //make rcp's for every list item so that they will go out of scope and be
//   deleted
//
//   for (int i = 0; i < cpp_list->listItems().count(); i++) {
//     delete cpp_list->item(i).release();
//
//   }
//   cpp_list->removeAllItems();
//
// }
//
// void rive_VMIListRemoveItemAt(Rive_VMI_List *self, int index) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   cpp_list->removeItem(index);
//
// }
//
// Rive_VMI_ListItem* rive_VMIListPop(Rive_VMI_List *self) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   return reinterpret_cast<Rive_VMI_ListItem*>(cpp_list->pop().release());
//
// }
// void rive_VMIListSetCallback(Rive_VMI_List *self, void (*callback)()) {
//   auto *cpp_list = reinterpret_cast<rive::ViewModelInstanceList *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelListChanged>(callback);
//
//   cpp_list->onChanged(cpp_callback);
//
// }
//
// bool rive_getVMIBooleanValue(Rive_VMI_Boolean *self) {
//   auto *cpp_bool = reinterpret_cast<rive::ViewModelInstanceBoolean *>(self);
//   return cpp_bool->propertyValue();
// }
//
// void rive_setVMIBooleanValue(Rive_VMI_Boolean *self, bool value) {
//   auto *cpp_bool = reinterpret_cast<rive::ViewModelInstanceBoolean *>(self);
//   cpp_bool->propertyValue(value);
// }
//
// void rive_VMIBooleanSetCallback(Rive_VMI_Boolean *self, void (*callback)()) {
//   auto *cpp_bool = reinterpret_cast<rive::ViewModelInstanceBoolean *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelBooleanChanged>(callback);
//
//   cpp_bool->onChanged(cpp_callback);
//
// }
//
// uint32_t rive_getVMITriggerValue(Rive_VMI_Trigger *self) {
//   auto *cpp_trig = reinterpret_cast<rive::ViewModelInstanceTrigger *>(self);
//   return cpp_trig->propertyValue();
// }
// void rive_fireVMITrigger(Rive_VMI_Trigger *self) {
//   auto *cpp_trig = reinterpret_cast<rive::ViewModelInstanceTrigger *>(self);
//   cpp_trig->trigger();
// }
//
//
// void rive_VMITriggerSetCallback(Rive_VMI_Trigger *self, void (*callback)()) {
//   auto *cpp_trig = reinterpret_cast<rive::ViewModelInstanceTrigger *>(self);
//   auto *cpp_callback =
//   reinterpret_cast<rive::ViewModelTriggerChanged>(callback);
//
//   cpp_trig->onChanged(cpp_callback);
//
// }
//
// Rive_ViewModelInstance * rive_getVMIViewModelInstance(Rive_VMI_ViewModel
// *self) {
//   auto *cpp_vm = reinterpret_cast<rive::ViewModelInstanceViewModel *>(self);
//   return
//   reinterpret_cast<Rive_ViewModelInstance*>(cpp_vm->referenceViewModelInstance().release());
// }
//
// uint32_t rive_getVMIViewModelValue(Rive_VMI_ViewModel *self) {
//   auto *cpp_vm = reinterpret_cast<rive::ViewModelInstanceViewModel *>(self);
//   return cpp_vm->propertyValue();
// }
//
// void rive_setVMIViewModelValue(Rive_VMI_ViewModel *self, uint32_t value) {
//   auto *cpp_vm = reinterpret_cast<rive::ViewModelInstanceViewModel *>(self);
//   cpp_vm->propertyValue(value);
// }

// TODO: figure out how to release

// void rive_VMRuntimeRelease(Rive_ViewModelInstanceRuntime* instance) {
//   auto* cpp_instance = reinterpret_cast<rive::ViewModelInstanceRuntime*>()
//   rive::rcp<rive::ViewModelInstanceRuntime >
//   instance_to_release(reinterpret_cast<rive::File*>(file));
//
// }

} // end extern "C"
