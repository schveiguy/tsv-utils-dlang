#! /bin/sh

## Most tsv-sample testing is done as unit tests. Tests executed by this script are run
## against the final executable. This provides a sanity check that the final executable
## is good. Tests are easy to run in this format, so there is overlap. However, these
## tests do not test edge cases as rigorously as unit tests. Instead, these tests focus
## on areas that are hard to test in unit tests.
##
## Portability note: Many of the tests here rely on generating consistent random numbers
## across different platforms when using the same random seed. So far this has succeeded
## on several different platorm, compiler, and library versions. However, it is certainly
## possible this condition will not hold on other platforms.
##
## For tsv-sample, this portability implies generating the same results on different 
## platforms when using the same random seed. This is NOT part of tsv-sample guarantees,
## but it is convenient for testing. If platforms are identified that do not generate
## the same results these tests will need to be adjusted.

if [ $# -le 1 ]; then
    echo "Insufficient arguments. A program name and output directory are required."
    exit 1
fi

prog=$1
shift
odir=$1
echo "Testing ${prog}, output to ${odir}"

## Three args: program, args, output file
runtest () {
    echo "" >> $3
    echo "====[tsv-sample $2]====" >> $3
    $1 $2 >> $3 2>&1
    return 0
}

basic_tests_1=${odir}/basic_tests_1.txt

echo "Basic tests set 1" > ${basic_tests_1}
echo "-----------------" >> ${basic_tests_1}

runtest ${prog} "--header --static-seed input3x10.tsv input3x25.tsv" ${basic_tests_1}
runtest ${prog} "-H -s --print-random input3x10.tsv input3x25.tsv" ${basic_tests_1}
runtest ${prog} "-H -s -p --field 3 input3x10.tsv input3x25.tsv" ${basic_tests_1}
runtest ${prog} "-H -s -p -f 3 --num 15 input3x10.tsv input3x25.tsv" ${basic_tests_1}
runtest ${prog} "-H -s -p -n 15 input3x10.tsv input3x25.tsv" ${basic_tests_1}
runtest ${prog} "-H -s -n 100 input3x10.tsv input3x25.tsv" ${basic_tests_1}

runtest ${prog} "--static-seed input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}
runtest ${prog} "-s --print-random input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}
runtest ${prog} "-s -p --field 1 input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}
runtest ${prog} "-s -p -f 1 --num 15 input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}
runtest ${prog} "-s -p -n 5 input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}
runtest ${prog} "-s -n 100 input2x10_noheader.tsv input2x5_noheader.tsv" ${basic_tests_1}

runtest ${prog} "--delimiter @ -H --static-seed input2x7_atsign.tsv" ${basic_tests_1}
runtest ${prog} "-d @ -H -s -p input2x7_atsign.tsv" ${basic_tests_1}
runtest ${prog} "-d @ -H -s -p -f 2 input2x7_atsign.tsv" ${basic_tests_1}
runtest ${prog} "-d @ -H -s -p -f 2 -n 3 input2x7_atsign.tsv" ${basic_tests_1}
runtest ${prog} "-d @ -H -s -p -n 20 input2x7_atsign.tsv" ${basic_tests_1}

## Need to run at least one test with the unpredictable seed. Can't compare the
## results, so check the number of lines returned. Check standard input also.
## runtest can't do these, write these out by hand.
## Note: The "tr -d ' '" construct strips whitespace, which differs between 'wc -l' implementations.
echo "" >> ${basic_tests_1}; echo "====[tsv-sample -H input3x10.tsv | wc -l | tr -d ' ']====" >> ${basic_tests_1}
${prog} -H input3x10.tsv | wc -l | tr -d ' ' >> ${basic_tests_1} 2>&1

echo "" >> ${basic_tests_1}; echo "====[cat input3x10.tsv tsv-sample -H -p | wc -l | tr -d ' ']====" >> ${basic_tests_1}
cat input3x10.tsv | ${prog} -H -p | wc -l | tr -d ' ' >> ${basic_tests_1} 2>&1

echo "" >> ${basic_tests_1}; echo "====[cat input3x10.tsv tsv-sample -H -p -f 3 -- - input3x25.tsv | wc -l | tr -d ' ']====" >> ${basic_tests_1}
cat input3x10.tsv | ${prog} -H -p -f 3 -- - input3x25.tsv | wc -l | tr -d ' ' >> ${basic_tests_1} 2>&1

echo "" >> ${basic_tests_1}; echo "====[cat input3x10.tsv tsv-sample -H -p -f 3 -n 10 -- - input3x25.tsv | wc -l | tr -d ' ']====" >> ${basic_tests_1}
cat input3x10.tsv | ${prog} -H -p -f 3 -n 10 -- - input3x25.tsv | wc -l | tr -d ' ' >> ${basic_tests_1} 2>&1

## Error cases

error_tests_1=${odir}/error_tests_1.txt

echo "Error test set 1" > ${error_tests_1}
echo "----------------" >> ${error_tests_1}

runtest ${prog} "no_such_file.tsv" ${error_tests_1}
runtest ${prog} "--no-such-param input3x25.tsv" ${error_tests_1}
runtest ${prog} "-d ß input3x25.tsv" ${error_tests_1}
runtest ${prog} "-H -f 2 input3x25.tsv" ${error_tests_1}
runtest ${prog} "-f 3 input3x25.tsv" ${error_tests_1}
runtest ${prog} "-H -f 11 input3x25.tsv" ${error_tests_1}
