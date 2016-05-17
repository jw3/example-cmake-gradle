//
// Created by wassj on 2/23/2016.
//

#include <jni.h>
#include "example_Example.h"
#include <iostream>

JNIEXPORT jstring JNICALL Java_example_Example_messageImpl(JNIEnv* env, jobject obj)
{
    std::cout << "in jni call" << std::endl;
    return env->NewStringUTF("from native");
}
