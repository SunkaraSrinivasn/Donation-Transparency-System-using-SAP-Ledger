" --- 1. THE BUFFER DEFINITION ---
" This holds your data in memory during the transaction
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_donation_buffer TYPE TABLE OF zdonation_ledger.
ENDCLASS.

" --- 2. HANDLER CLASS (Interaction Phase) ---
CLASS lhc_Donation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Donation RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Donation.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Donation.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Donation.

    METHODS read FOR READ
      IMPORTING keys FOR READ Donation RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Donation.
ENDCLASS.

CLASS lhc_Donation IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_donation_create>).

      " Generate a fresh UUID if one wasn't provided
      DATA(lv_uuid) = <ls_donation_create>-DonationID.
      IF lv_uuid IS INITIAL.
         TRY.
             lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
           CATCH cx_uuid_error.
         ENDTRY.
      ENDIF.

      " Move UI data into the Static Buffer (lcl_buffer)
      APPEND VALUE #(
        donation_id     = lv_uuid
        donor_name      = <ls_donation_create>-DonorName
        amount          = <ls_donation_create>-Amount
        currency        = <ls_donation_create>-Currency
        purpose         = <ls_donation_create>-Purpose
        donation_date   = <ls_donation_create>-DonationDate
        status          = <ls_donation_create>-Status
        last_changed_at = <ls_donation_create>-LastChangedAt
      ) TO lcl_buffer=>mt_donation_buffer.

      " Map the temporary Frontend ID (%cid) to our UUID
      APPEND VALUE #( %cid       = <ls_donation_create>-%cid
                      DonationID = lv_uuid ) TO mapped-donation.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    " Implementation for updates would go here
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    " Allows Fiori to display data after save
    SELECT * FROM zdonation_ledger
      FOR ALL ENTRIES IN @keys
      WHERE donation_id = @keys-DonationID
      INTO TABLE @DATA(lt_read_results).

    result = CORRESPONDING #( lt_read_results MAPPING DonationID = donation_id ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

" --- 3. SAVER CLASS (Save Phase) ---
CLASS lsc_ZI_DONATIONLEDGER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_DONATIONLEDGER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " Push data from the Memory Buffer into the Actual Database Table
    IF lcl_buffer=>mt_donation_buffer IS NOT INITIAL.
      INSERT zdonation_ledger FROM TABLE @lcl_buffer=>mt_donation_buffer.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
    " Clear the memory so the next transaction starts fresh
    CLEAR lcl_buffer=>mt_donation_buffer.
  ENDMETHOD.

ENDCLASS.
