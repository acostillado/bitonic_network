-------------------------------------------------------------------------------
-- Title      : tb_random2bitonic
-- Project    : Linux_Zybo
-------------------------------------------------------------------------------
-- File        : tb_random2bitonic.vhd
-- Author      : Daniel Jiménez Mazure
-- Company     : DDR/TICH
-- Created     : 02/05/2020 - 22:12:36
-- Last update : 02/05/2020 - 22:12:36
-- Synthesizer : Vivado 2018.3
-- FPGA        : Zynq7010
-------------------------------------------------------------------------------
-- Description: Test Bench para el módulo de ordenamiento en estapa de
-- ordenamiento tipo bitonic (monotónico/bitónico)
-------------------------------------------------------------------------------
-- Copyright (c) 2020 DDR/TICH
-------------------------------------------------------------------------------
-- Revisions  :
-- Date/Time                Version               Engineer
-- 01/05/2020 - 17:52:42      1.0             dasjimaz@gmail.com
-- Description :
-- Created
-------------------------------------------------------------------------------
-- SVN Commit : $Date$
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.medianFilter_pkg.all;


entity tb_random2bitonic is
  generic(
    G_PIXEL_WIDTH : integer := 24
    );
end entity tb_random2bitonic;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture simulation of tb_random2bitonic is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant C_RESET_PERIOD : time := 0.1 us;
  constant CLK_125_PERIOD : time := 8.0 ns;
  --
  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component random2bitonic is
    generic (
      G_PIXEL_WIDTH : integer);
    port (
      PIXEL_WINDOW  : in  t_pixel_array8;
      PIXEL_BITONIC : out t_pixel_array8);
  end component random2bitonic;
  --
  component bitonic2sort is
    generic (
      G_PIXEL_WIDTH : integer);
    port (
      PIXEL_BITONIC : in  t_pixel_array8;
      PIXEL_SORTED  : out t_pixel_array8
      );
  end component bitonic2sort;
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal ACLK          : std_logic;
  signal ARSTN         : std_logic;
  signal PIXEL_WINDOW  : t_pixel_array8;
  signal PIXEL_BITONIC : t_pixel_array8;
  signal PIXEL_SORTED  : t_pixel_array8;

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
  -- UUT
  -----------------------------------------------------------------------------
  Inst_random2bitonic_1 : component random2bitonic
    generic map (
      G_PIXEL_WIDTH => G_PIXEL_WIDTH
      )
    port map (
      PIXEL_WINDOW  => PIXEL_WINDOW,
      PIXEL_BITONIC => PIXEL_BITONIC
      );

  Inst_bitonic2sort : entity work.bitonic2sort
    generic map (
      G_PIXEL_WIDTH => G_PIXEL_WIDTH)
    port map (
      PIXEL_BITONIC => PIXEL_BITONIC,
      PIXEL_SORTED  => PIXEL_SORTED
      );
  -----------------------------------------------------------------------------
  -- Main process
  ----------------------------------------------------------------------------
  MAIN_PROC : process
    variable i : integer := 0;
    variable j : integer := 0;
  --
  begin
    wait for C_RESET_PERIOD;
    --
    report "TB Starting ... " severity note;
    ---------------------------------------------------------------------------
    report " Create pixels for 1 frame" severity note;
    ---------------------------------------------------------------------------
    wait until rising_edge(ACLK);

    GEN_DATA : for i in 0 to 7 loop
      PIXEL_WINDOW(i) <= std_logic_vector(to_unsigned(i, 24));
    end loop;

    wait until rising_edge(ACLK);

    SHOW_RESULT : for i in 0 to 7 loop
      report "Data: " & integer'image(to_integer(unsigned(PIXEL_BITONIC(i))));
    end loop;
    
    wait for 2 us;
    wait until rising_edge(ACLK);
    
    PIXEL_WINDOW(0) <= std_logic_vector(to_unsigned(11, 24));
    PIXEL_WINDOW(1) <= std_logic_vector(to_unsigned(13, 24));
    PIXEL_WINDOW(2) <= std_logic_vector(to_unsigned(16, 24));
    PIXEL_WINDOW(3) <= std_logic_vector(to_unsigned(35, 24));
    PIXEL_WINDOW(4) <= std_logic_vector(to_unsigned(15, 24));
    PIXEL_WINDOW(5) <= std_logic_vector(to_unsigned(4, 24));
    PIXEL_WINDOW(6) <= std_logic_vector(to_unsigned(3, 24));
    PIXEL_WINDOW(7) <= std_logic_vector(to_unsigned(1, 24));
    


    report "---------------------------------------------------------------------------" severity note;
    report " TEST BENCH ENDED SUCCESFULLLY" severity note;
    report "---------------------------------------------------------------------------" severity note;
    wait;

  end process;


end simulation;







