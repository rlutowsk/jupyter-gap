import requests
import gzip
import bz2
import json
import os
import tarfile

# URL pliku JSON
gap_ver = os.environ.get("GAP_VER")
if gap_ver is None:
    gap_ver = "4.14.0"
url = f"https://github.com/gap-system/gap/releases/download/v{gap_ver}/package-infos.json.gz"

# Pobierz plik
response = requests.get(url, stream=True)
response.raise_for_status()

# Zapisz plik do pamięci
gz_file = gzip.GzipFile(fileobj=response.raw)

# Wczytaj dane JSON
data = json.load(gz_file)

# Wybierz pakiety do pobrania
# Pobierz listę pakietów ze zmiennej środowiskowej
packages_env = os.environ.get("GAP_PACKAGES")
if packages_env:
    selected_packages = packages_env.split()
else:
    selected_packages = [
    "alnuth",
    "autpgrp",
    "crisp",
    "crypting",
    "ctbllib",
    "factint",
    "fga",
    "gapdoc",
    "help",
    "io",
    "irredsol",
    "json",
    "jupyterkernel",
    "laguna",
    "orb",
    "polenta",
    "polycyclic",
    "primgrp",
    "profiling",
    "resclasses",
    "smallgrp",
    "sophus",
    "tomlib",
    "transgrp",
    "uuid",
    "zeromqinterface"
    ]

# Pobierz i rozpakuj wybrane pakiety
for package in selected_packages:
    if package in data:
        package_info = data[package]
        package_url = package_info["ArchiveURL"]
        archive_formats = package_info["ArchiveFormats"].split()
        # print(f"Pobieranie pakietu: {package} z {package_url}")

        # we try only .tar.gz and .tar.bz2 formats
        formats_to_try = [".tar.gz", ".tar.bz2"]

        for format in formats_to_try:
            if format in archive_formats:
                filename = f"{package}{format}"
                try:
                    # download package
                    print(f"downloading package {package} ... ", end="", flush=True)
                    response = requests.get(f"{package_url}{format}", stream=True)
                    response.raise_for_status()

                    # save to file
                    with open(filename, "wb") as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            f.write(chunk)

                    # unpack
                    with tarfile.open(filename, f"r:{format[5:]}") as tar:
                        members = tar.getmembers()
                        folder_name = members[0].name.split("/")[0]
                        tar.extractall()

                    # rename folder
                    if folder_name != package:
                        os.rename(folder_name, package)
                    # remove the archive
                    os.remove(filename)

                    # we are finished here
                    print("done")
                    break
                except Exception as e:
                    print(f"failed: {e}")
                    if os.path.exists(filename):
                        os.remove(filename)
        else:
            print(f"failed: format not found")
    else:
        print(f"package {package} not found")
