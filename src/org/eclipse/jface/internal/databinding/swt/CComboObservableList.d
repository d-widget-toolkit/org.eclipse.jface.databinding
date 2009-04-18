/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.CComboObservableList;
import org.eclipse.jface.internal.databinding.swt.SWTObservableList;

import java.lang.all;

import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.swt.custom.CCombo;

/**
 * @since 3.2
 * 
 */
public class CComboObservableList : SWTObservableList {

    private final CCombo ccombo;

    /**
     * @param ccombo
     */
    public this(CCombo ccombo) {
        super(SWTObservables.getRealm(ccombo.getDisplay()));
        this.ccombo = ccombo;
    }

    protected int getItemCount() {
        return ccombo.getItemCount();
    }

    protected void setItems(String[] newItems) {
        ccombo.setItems(newItems);
    }

    protected String[] getItems() {
        return ccombo.getItems();
    }

    protected String getItem(int index) {
        return ccombo.getItem(index);
    }

    protected void setItem(int index, String string) {
        ccombo.setItem(index, string);
    }
}
