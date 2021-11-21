library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    VOUT    : out std_logic;
    DOUT_x  : out std_logic_vector(9 downto 0);
	DOUT_y  : out std_logic_vector(9 downto 0);
	DOUT_z  : out std_logic_vector(9 downto 0);
    H0      : out std_logic_vector(9 downto 0);
    H1      : out std_logic_vector(9 downto 0);
    H2      : out std_logic_vector(9 downto 0);
    H3      : out std_logic_vector(9 downto 0);
    H4      : out std_logic_vector(9 downto 0);
    H5      : out std_logic_vector(9 downto 0);
    H6      : out std_logic_vector(9 downto 0);
    H7      : out std_logic_vector(9 downto 0);
    H8      : out std_logic_vector(9 downto 0);
    H9      : out std_logic_vector(9 downto 0);
    H10      : out std_logic_vector(9 downto 0);
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

  constant tco : time := 1 ns;
  constant Ts : time := 10 ns;
  --signal toggle : std_logic := '0';
  signal sEndSim : std_logic;
  signal END_SIM_i : std_logic_vector(0 to 11);  

begin  -- beh

  H0 <= conv_std_logic_vector(-1,10);
  H1 <= conv_std_logic_vector(-7,10);
  H2 <= conv_std_logic_vector(-13,10);
  H3 <= conv_std_logic_vector(32,10); 
  H4 <= conv_std_logic_vector(140,10);
  H5 <= conv_std_logic_vector(203,10);
  H6 <= conv_std_logic_vector(140,10);
  H7 <= conv_std_logic_vector(32,10);
  H8 <= conv_std_logic_vector(-13,10);
  H9 <= conv_std_logic_vector(-7,10);
  H10 <= conv_std_logic_vector(-1,10);
  
  process (CLK, RST_n)
    file fp_in : text open READ_MODE is "../matlab/samples.txt";
    variable line_in : line;
    variable x, y, z : integer;
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      DOUT_x <= (others => '0') after tco;
	  DOUT_y <= (others => '0') after tco;
	  DOUT_z <= (others => '0') after tco;
      VOUT <= '0' after tco;
      sEndSim <= '0' after tco;
    elsif CLK'event and CLK = '1' then --and toggle = '0' then  -- rising clock edge
      if not endfile(fp_in) then
        readline(fp_in, line_in);
        read(line_in, x);
		readline(fp_in, line_in);
        read(line_in, y);
		readline(fp_in, line_in);
        read(line_in, z);
        DOUT_x <= conv_std_logic_vector(x, 10) after tco;
		DOUT_y <= conv_std_logic_vector(y, 10) after tco;
		DOUT_z <= conv_std_logic_vector(z, 10) after tco;
        VOUT <= '1' after tco;
        sEndSim <= '0' after tco;
	  else
		VOUT <= '0' after tco;        
		sEndSim <= '1' after tco;
      end if;
    --elsif CLK'event and CLK = '1' and toggle = '1' then
	--	VOUT <= '0' after tco;
    end if;
  end process;
  
--VIN_toggling : process -- dummy process used to verify that the circuit works properly even when VIN goes to zero
  --begin
	--wait for 30*Ts/2;
	--toggle <= '1';
	--wait for Ts;
	--toggle <= '0';
	--wait;
  --end process;
  
  
  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0') after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim after tco;
      END_SIM_i(1 to 11) <= END_SIM_i(0 to 10) after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(11);  

end beh;
