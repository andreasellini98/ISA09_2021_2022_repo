# needed modules
import sys
import os

NaN_value_bin = "01111111111111111111111111111111"

inf_value_bin = "01111111100000000000000000000000"

NaN_value = 1e40

inf_value = 1e308

n_bit_exp = 8

n_bit = 32

tot_errors = 0

# list of VHDL input files to use as sources of data
IN_files = []

# list of VHDL output files to use as sources of data
OUT_files = []

# name of log file
log_file_name = "log.txt"

LOG_file = open(log_file_name, 'w')

# opening of necessary files (output, input)
to_open_IN = "fp_samples.hex"
to_open_OUT = "fp_results.txt"

def print_error(error_str):
    print("ERROR encountered!")
    print(error_str)


# function to convert a hexadecimal number to its binary representation
def hex_to_bin(hex_number):
    hex_number = hex_number.strip()
    num_of_bits = 32
    scale = 16
    bin_number = bin(int(hex_number, scale))[2:].zfill(num_of_bits)

    return bin_number


# function to convert a binary number on 32 bit of its float value
def bin_to_float32(bin_number):
    bin_number = bin_number.strip()
    # considering special cases
    if bin_number == NaN_value_bin:
        fp_number = NaN_value
    elif bin_number[1:] == inf_value_bin[1:]:
        fp_number = inf_value
        if bin_number[0] == "1":
            fp_number = -fp_number
    else:
        man = int(bin_number[n_bit_exp + 1:], 2)
        exp = int("0" + bin_number[1:n_bit_exp + 1], 2) - 127
        sign = bin_number[0]
        if exp == -127:
            fp_number = 0
        else:
            fp_number = (1 + (man * 2 ** (-(n_bit - n_bit_exp - 1)))) * (2 ** exp)
        if sign == "1":
            fp_number = -fp_number
    return fp_number


def check_fp_multiplier(in_file, out_file, in_name, out_name):
    global errors
    log_list = []
    flag = 0

    for current_line_IN in in_file:
        # reading inputs
        if flag == 0:
            op1 = current_line_IN
            flag = 1

        else:
            if flag == 1:
                flag = 0
                op2 = current_line_IN

                op1_float = bin_to_float32(hex_to_bin(op1.strip()))
                op2_float = bin_to_float32(hex_to_bin(op2.strip()))

                correct_res = op1_float * op2_float

                current_line_out = out_file.readline()
                if not current_line_out:
                    print_error("The file " + in_name + " has more lines than the corrsponding " + out_name + " file.")
                else:
                    sim = bin_to_float32(current_line_out.strip())
                    error = (float(correct_res) - float(sim))

                    if float(correct_res) != 0.0:
                        error = float(error) / float(correct_res)

                    if abs(error) > 6e-7:
                        errors = errors + 1
                    else:
                        error = 0

                    log_list.append("{:20}\t{:20}\t=\t{:20}\t\t{:20}\t\t{:20}".format(str(float(op1_float)), str(float(op2_float)), str(bin_to_float32(current_line_out[:-1])), str(correct_res), str(error)))

    return log_list


try:
    IN_file = open(to_open_IN, 'r')

except:
    print_error("Cannot open file " + to_open_IN)
    
else:
    
    try:
        OUT_file = open(to_open_OUT, 'r')

    except:
        IN_file.close()
        print_error("Cannot open file " + to_open_OUT)

    else:
        # variable to count the partial number of errors (for each file)
        errors = 0
        log_list = check_fp_multiplier(IN_file, OUT_file, to_open_IN, to_open_OUT)

        # print header on log file
        LOG_file.write("\n--------------------------------------------------------\n")
        LOG_file.write("Check results for the fp multiplier \n\n")
        LOG_file.write("Operand1 \t\tOperand2 \t\t\tSimulation Result \t\tCorrect Value \t\t\tError\n")

        # printing the obtained results on log file
        for log_str in log_list:
            LOG_file.write(log_str + "\n")
        # printing of the final summary of each check on log file
        LOG_file.write("\n\nEncountered errors: " + str(errors) + "\n")
    
        OUT_file.close()
        IN_file.close()