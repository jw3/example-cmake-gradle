//
// Created by wassj on 2/23/2016.
//

#include <jni.h>
#include "example_Example.h"

JNIEXPORT jstring JNICALL Java_example_Example_messageImpl(JNIEnv* env, jobject obj)
{
    return env->NewStringUTF("from native");
}
