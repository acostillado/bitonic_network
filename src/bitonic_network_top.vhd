-------------------------------------------------------------------------------
-- Company     : Barcelona Supercomputing Center (BSC)
-- Engineer    : Daniel Jiménez Mazure
-- *******************************************************************
-- File       : Bitonic_Network.vhd
-- Author     : $Autor: dasjimaz@gmail.com $
-- Date       : $Date: 2021-05-06 $
-- Revisions  : $Revision: $
-- Last update: 2021-05-15
-- *******************************************************************
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bitonic Network. Top file. It instantiates two stages:
-- 1) Sort Random elements in a Bitonic sequence
-- 2) Sort a Bitonic sequence 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;


entity Bitonic_Network is
  generic(
    G_NETWORK_INPUTS : integer := 8;
    G_ELEMENT_WIDTH  : integer := 64;
    G_PIPE_CYCLES    : integer := 2                           --retiming?
    );
  port(
    CLK        : in  std_logic;
    CTRL       : in  std_logic_vector(C_NCOMP-1 downto 0);  -- 2stages
    RES        : out std_logic_vector(C_NCOMP-1 downto 0);  -- 2stages
    RANDOM_IN  : in  t_network_array(0 to G_NETWORK_INPUTS-1);
    SORTED_OUT : out t_network_array(0 to G_NETWORK_INPUTS-1)
    );
end Bitonic_Network;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of Bitonic_Network is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
--  signal s_element_bitonic : t_network_array(0 to G_NETWORK_INPUTS-1)(G_ELEMENT_WIDTH-1 downto 0);
--  signal s_element_sorted  : t_network_array(0 to G_NETWORK_INPUTS-1)(G_ELEMENT_WIDTH-1 downto 0);

  signal s_element_bitonic : t_network_array(0 to G_NETWORK_INPUTS-1);
  signal s_element_sorted  : t_network_array(0 to G_NETWORK_INPUTS-1);


begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- Sorting network (8 elements)
  -----------------------------------------------------------------------------

  Inst_random2bitonic : entity work.random2bitonicNode
    port map (
      CLK         => CLK,
      CTRL        => CTRL(C_NCOMP/2-1 downto 0),
      RES         => RES(C_NCOMP/2-1 downto 0),
      RANDOM_IN   => RANDOM_IN,
      BITONIC_OUT => s_element_bitonic
      );

  Inst_bitonic2sort : entity work.bitonic2sortNode
    port map (
      CLK        => CLK,
      CTRL       => CTRL(C_NCOMP-1 downto C_NCOMP/2),
      RES        => RES(C_NCOMP-1 downto C_NCOMP/2),
      BITONIC_IN => s_element_bitonic,
      SORTED_OUT => s_element_sorted
      );


  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------
  SORTED_OUT <= s_element_sorted;

end architecture RTL;
