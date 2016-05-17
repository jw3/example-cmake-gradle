#include <iostream>
#include <jni.h>
#include <windows.h>
#include <cstdlib>

typedef jint (APIENTRY *fpCJVM)(JavaVM**, void**, void*);

int main(int c, char** v)
{
    if(!c) {
        std::cerr << "error; CLASSPATH not set" << std::endl;
    }

    const char* env_val = std::getenv("JRE_HOME");
    std::string jre_home = env_val ? env_val : "";
    if(jre_home.empty()) {
        std::cerr << "error; JRE_HOME not set" << std::endl;
        return -1;
    }


    JavaVMOption* options = new JavaVMOption[2];
    options[0].optionString = "-Djava.class.path=C:/Users/wassj/ClionProjects/example-cmake/build/libs/example-cmake-gradle-0.1-SNAPSHOT.jar";
    options[1].optionString = "-verbose:jni";

//C:/Users/wassj/ClionProjects/example-cmake/build/classes/main
    JavaVMInitArgs vm_args;
    vm_args.version = JNI_VERSION_1_8;
    vm_args.ignoreUnrecognized = JNI_TRUE;
    vm_args.nOptions = 2;
    vm_args.options = options;





    HINSTANCE hVM = LoadLibrary("C:\\Program Files (x86)\\Java\\jre1.8.0_73\\bin\\client\\jvm.dll");
    if(!hVM){
        DWORD dwe = GetLastError();
        std::cerr << "failed to load jvm lib " << dwe << std::endl;
        return -1;
    }
    JNIEnv *env = 0;
    JavaVM *jvm = 0;

    // get the address of the first JNI call and create the VM
    fpCJVM CreateJavaVM = (fpCJVM)GetProcAddress(hVM, "JNI_CreateJavaVM");
    if(!CreateJavaVM){
        std::cerr << "failed to get CreateJavaVM function " << hVM << std::endl;
        return -1;
    }
    if(JNI_OK != CreateJavaVM(&jvm, (void**)&env, &vm_args)){
        std::cerr << "failed to create vm" << std::endl;
        return -1;
    }



    jclass cls = env->FindClass("example/Example");
    jmethodID ctor = env->GetMethodID(cls, "<init>", "()V");
    jobject obj = env->NewObject(cls, ctor);
    jmethodID mid = env->GetMethodID(cls, "message", "()Ljava/lang/String;");
    jstring msg = (jstring)env->CallObjectMethod(obj, mid);
    std::string str = env->GetStringUTFChars(msg, 0);

    std::cout << "res: " << str << std::endl;

    return 0;
}