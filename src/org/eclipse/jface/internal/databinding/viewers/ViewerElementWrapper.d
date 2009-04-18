/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 215531)
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ViewerElementWrapper;

import java.lang.all;

import org.eclipse.jface.viewers.IElementComparer;

/**
 * A wrapper class for viewer elements, which uses an {@link IElementComparer}
 * for computing {@link Object#equals(Object) equality} and
 * {@link Object#hashCode() hashes}.
 * 
 * @since 1.2
 */
public class ViewerElementWrapper {
    private final Object element;
    private final IElementComparer comparer;

    /**
     * Constructs a ViewerElementWrapper wrapping the given element
     * 
     * @param element
     *            the element being wrapped
     * @param comparer
     *            the comparer to use for computing equality and hash codes.
     */
    public this(Object element, IElementComparer comparer) {
        if (comparer is null)
            throw new NullPointerException();
        this.element = element;
        this.comparer = comparer;
    }

    public override equals_t opEquals(Object obj) {
        if (!(null !is cast(ViewerElementWrapper)obj)) {
            return false;
        }
        return comparer.opEquals(element, (cast(ViewerElementWrapper) obj).element);
    }

    public override hash_t toHash() {
        return comparer.toHash(element);
    }

    Object unwrap() {
        return element;
    }
}
