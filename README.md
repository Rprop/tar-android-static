# tar-android-static
statically linked GNU Tar binaries built with the Android NDK r23c

## Information
Read more about tar on its [webpage](https://www.gnu.org/software/tar/).  
Sources are available [here](https://ftp.gnu.org/gnu/tar/).

## Building
```
ANDROID_SDK_INT=31
NDK_PATH=/path/to/android-ndk-r23c

export LDFLAGS="$LDFLAGS -static"
export CFLAGS="$CFLAGS -static -Wno-unused-command-line-argument -pie"
export CC="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android"$ANDROID_SDK_INT"-clang"
./configure --host=aarch64-linux-android
make

export LDFLAGS="$LDFLAGS -static"
export CFLAGS="$CFLAGS -static -Wno-unused-command-line-argument -pie"
export CC="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi"$ANDROID_SDK_INT"-clang
./configure --host=arm-linux-androideabi
make
```

## Patching NDK
In case of 'ld: error: duplicate symbol: ****', patch libc.a is required since Android NDK does not have timezone_t.

```
ld: error: duplicate symbol: tzfree
>>> defined at time_rz.c
>>>            time_rz.o:(tzfree) in archive ../gnu/libgnu.a
>>> defined at localtime.c:1371 (bionic/libc/tzcode/localtime.c:1371)
>>>            localtime.o:(.text.tzfree+0x0) in archive $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_INT/libc.a
```

```
# tzalloc -> _zalloc
sed -i "s/\x74\x7A\x61\x6C\x6C\x6F\x63/\x5F\x7A\x61\x6C\x6C\x6F\x63/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/arm-linux-androideabi/$ANDROID_SDK_INT/libc.a
sed -i "s/\x74\x7A\x61\x6C\x6C\x6F\x63/\x5F\x7A\x61\x6C\x6C\x6F\x63/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_INT/libc.a

# tzfree -> _zfree
sed -i "s/\x74\x7A\x66\x72\x65\x65/\x5F\x7A\x66\x72\x65\x65/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/arm-linux-androideabi/$ANDROID_SDK_INT/libc.a
sed -i "s/\x74\x7A\x66\x72\x65\x65/\x5F\x7A\x66\x72\x65\x65/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_INT/libc.a

# localtime_rz -> _ocaltime_rz
sed -i "s/\x6C\x6F\x63\x61\x6C\x74\x69\x6D\x65\x5F\x72\x7A/\x5F\x6F\x63\x61\x6C\x74\x69\x6D\x65\x5F\x72\x7A/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/arm-linux-androideabi/$ANDROID_SDK_INT/libc.a
sed -i "s/\x6C\x6F\x63\x61\x6C\x74\x69\x6D\x65\x5F\x72\x7A/\x5F\x6F\x63\x61\x6C\x74\x69\x6D\x65\x5F\x72\x7A/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_INT/libc.a

# mktime_z -> _ktime_z
sed -i "s/\x6D\x6B\x74\x69\x6D\x65\x5F\x7A/\x5F\x6B\x74\x69\x6D\x65\x5F\x7A/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/arm-linux-androideabi/$ANDROID_SDK_INT/libc.a
sed -i "s/\x6D\x6B\x74\x69\x6D\x65\x5F\x7A/\x5F\x6B\x74\x69\x6D\x65\x5F\x7A/g" $NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_INT/libc.a
```

## Stripping
```
$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip -s ./src/tar
```
