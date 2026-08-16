class ahb_transaction extends uvm_sequence_item;
    `uvm_object_utils(ahb_transaction)

    // Data transaction
    rand bit hsize;
    rand bit [31:0] haddr;
    rand bit [31:0] hwrdata;
    rand bit [31:0] hrdata;
    rand bit [2:0] hsize;

    //Constrain
    constraint address_range {
        haddr < 32'h10000; 
    }
    constraint address_alignment {
        (hsize== 3'b001) -> (haddr[0]==0);
        (hsize== 3'b010) -> (haddr[1:0]==0);
    }
    function new(string name= "ahb_transaction");
        super.new(name);
    endfunction
endclass