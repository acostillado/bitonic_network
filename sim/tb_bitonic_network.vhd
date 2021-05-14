-------------------------------------------------------------------------------
-- Company     : Barcelona Supercomputing Center (BSC)
-- Engineer    : Daniel Jiménez Mazure
-- *******************************************************************
-- File       : Bitonic_Network.vhd
-- Author     : $Autor: dasjimaz@gmail.com $
-- Date       : $Date: 2021-05-06 $
-- Revisions  : $Revision: $
-- Last update: 2021-05-07
-- *******************************************************************
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bitonic sorting ot 2 elements using direcction as an input generic
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use ieee.math_real.uniform;
use ieee.math_real.floor;

library work;
use work.Bitonic_Network_pkg.all;


entity tb_bitonic_network is
  generic(
    G_PIPE_CYCLES : integer := 2
    );
end entity tb_bitonic_network;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture simulation of tb_bitonic_network is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant C_RESET_PERIOD : time      := 1 us;
  constant CLK_125_PERIOD : time      := 8.0 ns;
  constant C_ELEMENT_WIDTH : integer  := 64;
  --
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal ACLK             : std_logic;
  signal ARSTN            : std_logic;
  signal RANDOM_SEQUENCE  : t_network_array(0 to 7);
  signal SORTED_SEQUENCE  : t_network_array(0 to 7); 
  --
  signal tb_finish        : std_logic := '0';


begin

  -----------------------------------------------------------------------------
  -- System Clocks
  -----------------------------------------------------------------------------
  process
  begin
    ACLK <= '1';
    wait for (CLK_125_PERIOD/2);
    ACLK <= '0';
    wait for (CLK_125_PERIOD/2);
  end process;

  --------------------------------------------------------------------------------
  --  RESET
  --------------------------------------------------------------------------------

  RESET_PROC : process
  begin
    ARSTN <= '0';
    wait for C_RESET_PERIOD;
    wait until rising_edge(ACLK);
    ARSTN <= '1';
    wait;
  end process;

  -----------------------------------------------------------------------------
  -- Random number generator
  -----------------------------------------------------------------------------
  process is
    variable seed1 : positive;
    variable seed2 : positive;
    variable x     : real;
    variable y     : integer;
  begin
    seed1 := 1;
    seed2 := 1;
    while (tb_finish = '0') loop
      for n in 1 to 8 loop
        uniform(seed1, seed2, x);
        y                    := integer(floor(x * 1024.0));
        report "Random number in 0 .. 1023: " & integer'image(y);
        RANDOM_SEQUENCE(n-1) <= std_logic_vector(to_unsigned(y, C_ELEMENT_WIDTH));
      end loop;
--    wait;
      wait until rising_edge(ACLK);
      seed1 := seed1 + 1;
      seed2 := seed2 + 1;
    end loop;
  end process;


  -----------------------------------------------------------------------------
  -- UUT
  -----------------------------------------------------------------------------
  Bitonic_Network_0 : entity work.Bitonic_Network
    generic map (
      G_PIPE_CYCLES => G_PIPE_CYCLES
      )
    port map (
      CLK        => ACLK,
      RANDOM_IN  => RANDOM_SEQUENCE,
      SORTED_OUT => SORTED_SEQUENCE
      );
  -----------------------------------------------------------------------------
  -- Main process
  ----------------------------------------------------------------------------
  MAIN_PROC : process
    variable i : integer := 0;
    variable j : integer := 0;
  --
  begin
    tb_finish <= '0';
    wait for C_RESET_PERIOD;
    --
    report "TB Starting ... " severity note;
    wait for 1 us;
    tb_finish <= '1';
    report "---------------------------------------------------------------------------" severity note;
    report " TEST BENCH ENDED SUCCESFULLLY" severity note;
    report "---------------------------------------------------------------------------" severity note;
    wait;

  end process;


end simulation;







