#!/usr/bin/env python
# pipe in binaries.csv from stdin

import sys, csv, subprocess, os

version = "1.0.0-RC0"
build = sys.argv[1]

root = subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).rstrip()
path = "{}/test/csit/docker".format(root)

with sys.stdin as f:
    reader = csv.DictReader(f)

    for row in reader:
        if len(sys.argv) < 3 or sys.argv[2]==row["filename"]:
            print row["filename"]

            if row["classifier"]:
                file = "{}-{}-{}.{}".format(row["artifactId"], version, row["classifier"], row["extension"])
                dest = "{}-{}-{}.{}".format(row["filename"], version, row["classifier"], row["extension"])
            else:
                file = "{}-{}.{}".format(row["artifactId"], version, row["extension"])
                dest = "{}-{}.{}".format(row["filename"], version, row["extension"])

            dir = "{}/{}".format(path, row["filename"])

            try:
                os.mkdir(dir)
            except OSError:
                pass

            # create empty Dockerfile if not exists
            dockerfile=open( "{}/Dockerfile".format(dir), "a" )
            dockerfile.close()

            outfile = open( "{}/50-microservice.txt".format(dir), "w" )
            
            url = "https://nexus.open-o.org/content/repositories/{}/{}/{}/{}/{}".format(build, row["groupId"].replace(".","/"), row["artifactId"], version, file )

            outfile.write("# 50-microservice.txt - AUTOGENERATED, DO NOT MODIFY MANUALLY\n\n")   
            outfile.write("# Set up microservice\n")

            
            outfile.write("RUN wget -q -O {} {}".format(dest, url))
            
            if row["extension"] == "tar.gz":
                outfile.write(" && tar -xf {}".format(dest))
            elif row["extension"] == "zip":
                outfile.write(" && unzip -q -o -B {}".format(dest))
            outfile.write(" && rm -f {}\n".format(dest))
            
            if row["port"]:
                outfile.write("EXPOSE {}\n".format(row["port"]))
            outfile.write("RUN echo Open-O {} {} > VERSION\n".format(version, build))
            outfile.write("\n\n")
            
            outfile.close()


            def symlink(flag, template):
                try:
                    os.remove("{}/{}".format(dir, template))
                except OSError:
                    pass
                if flag:
                    os.symlink("../templates/{}".format(template), "{}/{}".format(dir, template))

            symlink(True, "10-basebuild.txt")
            symlink(row["python"], "15-python.txt")
            symlink(row["mysql"], "20-mysql.txt")
            symlink(row["tomcat"], "30-tomcat.txt")
            symlink(True, "90-entrypoint.txt")
