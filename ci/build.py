import argparse
import os
import wget
import yaml
import shutil

environ = os.environ.copy()


parser = argparse.ArgumentParser(description='Build the project')
parser.add_argument('--tmpdir', default='/tmp/aplus-packages-build', help='Temporary directory')
parser.add_argument('--host', default='x86_64-aplus', help='Host architecture')
parser.add_argument('--root', default='.', help='Root directory')
parser.add_argument('--clean', action='store_true', help='Clean the temporary directory')
parser.add_argument('--verbose', action='store_true', help='Verbose output')
args = parser.parse_args()




def scan(path):

    for root, _, files in os.walk(path):

        for file in files:

            if not file.endswith('package.yml'):  
                continue  

            yield root


def resolve(packages, package, s):

    for p in packages:

        if '$PACKAGE_{}'.format(p['package'].upper()) not in s:
            continue

        s = s.replace('$PACKAGE_{}'.format(p['package'].upper()), os.path.join(args.tmpdir, p['package'] + '-' + p['version']))


    s = s.replace('$HOST', args.host)
    s = s.replace('$ROOT', args.root)
    s = s.replace('$TMP',  args.tmpdir)
    s = s.replace('$SYSROOT', os.path.join(args.tmpdir, package['package'] + '-' + package['version'], '__out'))
    s = s.replace('$PACKAGE', package['package'])
    s = s.replace('$VERSION', package['version'])    

    return s



def prepare(packages, package, env=True):

    srcdir = os.path.join(args.tmpdir, f'{package["package"]}-{package["version"]}')
    
    if not os.path.exists(os.path.join(srcdir, '__build')):
        os.mkdir(os.path.join(srcdir, '__build'))

    if not os.path.exists(os.path.join(srcdir, '__out')):
        os.mkdir(os.path.join(srcdir, '__out'))


    for k in os.environ:
        if k not in environ:
            os.unsetenv(k)

    if env and 'env' in package['build']:

        for env in package['build']['env']:

            for k, v in env.items():

                os.environ[k] = resolve(packages, package, v)
                os.putenv(k, os.environ[k])

                if args.verbose:
                    print(f'   + {k}={os.environ[k]}')

    return srcdir




def build(packages, package):

    if package['status'] == 'done':
        return


    if 'dependencies' in package:

        for dep in package['dependencies']:

            if args.verbose:
                print(f' - Dependency {dep}')

            for p in packages:

                if p['package'] != dep:
                    continue
            
                if p['status'] == 'done':
                    continue

                if p['status'] == 'building':
                    raise Exception(f'Circular dependency detected: {package} -> {dep}')

                build(packages, p)
                break



    package['status'] = 'building'

    srcdir = prepare(packages, package)
    curdir = os.curdir


    if 'configure' in package['build']:

        print(f' - Configuring {package["package"]}:{package["version"]}')

        opts = package["build"]["configure"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')

        os.chdir(os.path.join(srcdir, '__build'))
        os.system(f'{srcdir}/configure {" ".join(opts)} 1> configure.log 2> configure.err')
        os.chdir(curdir)





    if 'make' in package['build']:
    
        print(f' - Building {package["package"]}:{package["version"]}')

        opts = package["build"]["make"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')

        if 'configure' in package['build']:
            os.chdir(os.path.join(srcdir, '__build'))
        else:
            os.chdir(srcdir)

        os.system(f'make {" ".join(opts)} 1> make.log 2> make.err')
        os.chdir(curdir)



    if 'install' in package['build']:

        print(f' - Installing {package["package"]}:{package["version"]}')

        opts = package["build"]["install"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')

        if 'configure' in package['build']:
            os.chdir(os.path.join(srcdir, '__build'))
        else:
            os.chdir(srcdir)

        os.system(f'make install {" ".join(opts)} 1> install.log 2> install.err')
        os.chdir(curdir)


    package['status'] = 'done'




def stage_1(packages):

    print('Scanning for packages')

    for package in scan(args.root):

        with(open(os.path.join(package, 'package.yml'))) as fp:

            yml = yaml.safe_load(fp)

            if 'package' not in yml:
                continue

            if 'version' not in yml:
                continue

            if 'sources' not in yml:
                continue

            if 'build' not in yml:
                continue

            if args.verbose:
                print(f' - Found {yml["package"]}-{yml["version"]}')


            yml['root']   = package
            yml['status'] = 'init'

            packages.append(yml)

    return packages



def stage_2(packages):

    print('Fetching sources')

    for package in packages:

        print(f' - GET {package["package"]}:{package["version"]}')


        package['archives'] = []

        for source in package['sources']:

            source = resolve(packages, package, source)

            filename = wget.detect_filename(source)
            filename = os.path.join(args.tmpdir, filename)

            if args.verbose:
                print(f'   + {source}')

            if not os.path.exists(filename):
                wget.download(source, filename)
                print('')

            package['archives'].append(filename)

    return packages


def stage_3(packages):

    print('Unpacking packages')

    for package in packages:

        print(f' - Unpacking {package["package"]}:{package["version"]}')

        for archive in package['archives']:
            
            if args.verbose:
                print(f'   + {archive}')

            os.system(f'tar xf {archive} -C {args.tmpdir}')

    return packages


def stage_4(packages):

    print('Patching packages')

    for package in packages:

        print(f' - Patching {package["package"]}:{package["version"]}')

        srcdir = prepare(packages, package, False)
        curdir = os.curdir

        if 'patches' in package['build']:

            for patch in package['build']['patches']:

                patch = resolve(packages, package, patch)
                patch = os.path.join(package['root'], patch)

                if args.verbose:
                    print(f'   + {patch}')

                os.chdir(os.path.join(srcdir))
                os.system(f'patch -p1 -t --verbose < {patch} 1> __build/patch.log 2> __build/patch.err')
                os.chdir(curdir)


    return packages



def stage_5(packages):

    print('Build packages')

    for package in packages:
        build(packages, package)

    return packages


def stage_6(packages):

    print('Packaging packages')

    for package in packages:

        print(f' - Packaging {package["package"]}:{package["version"]}')

        srcdir = prepare(packages, package, False)
        curdir = os.curdir

        os.chdir(os.path.join(srcdir, '__out'))
        os.system(f'cp -R {package["root"]}/.pkg .')
        os.system(f'tar cJf {args.root}/{package["package"]}.tar.xz * .pkg')
        os.chdir(curdir)


def main():

    if not os.path.exists(args.tmpdir):
        os.mkdir(args.tmpdir)

    args.root = os.path.abspath(args.root)

    packages = []
    packages = stage_1(packages)
    packages = stage_2(packages)
    packages = stage_3(packages)
    packages = stage_4(packages)
    packages = stage_5(packages)
    packages = stage_6(packages)

    if args.clean:
        shutil.rmtree(args.tmpdir)


if __name__ == '__main__':
    main()
   

        