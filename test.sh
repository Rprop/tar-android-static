#!/system/bin/sh
op_type=$1
current_dir=$(pwd)
script_dir=$(dirname $(realpath $0))
tar_bin=$script_dir/tar
gzip_bin=gzip
#
echo ========
echo "op_type: "$op_type
echo "current_dir: "$current_dir
echo "script_dir: "$script_dir
echo "tar_bin: "$tar_bin
echo "gzip_bin: "$gzip_bin
#
echo ========
if [[ "$op_type" == "backup" ]]; then
    target_dir=$2
    output_dir=$3
    parent_dir=$(dirname $target_dir)
    target_dir_name=$(basename $target_dir)
    output_file_tar=$output_dir/$target_dir_name.tar
    #
    echo "target_dir: "$target_dir
    echo "output_dir: "$output_dir
    echo "parent_dir: "$parent_dir
    echo "target_dir_name: "$target_dir_name
    echo "output_file_tar: "$output_file_tar
    #
    cd $parent_dir
    chmod 0755 $tar_bin
    $tar_bin --selinux --xattrs --xattrs-include=* --numeric-owner -cpf  $output_file_tar $target_dir_name
    $gzip_bin -f -9 $output_file_tar
    cd $current_dir
    #
    echo ========
    echo "BACKUP TO "$output_file_tar.gz
elif [[ "$op_type" == "import" ]]; then
    target_gz_file=$2
    target_tar_file=$(dirname $target_gz_file)/$(basename $target_gz_file .gz)
    import_to_dir=$3
    #
    echo "target_gz_file: "$target_gz_file
    echo "target_tar_file: "$target_tar_file
    echo "import_to_dir: "$import_to_dir
    #
    cd $import_to_dir
    $gzip_bin -d -f -k $target_gz_file
    chmod 0755 $tar_bin
    $tar_bin --selinux --xattrs --xattrs-include=* --numeric-owner -xspf $target_tar_file
    cd $current_dir
    echo ========
    echo "IMPORT TO "$import_to_dir
else
    echo "ERROR"
fi
#
echo ========